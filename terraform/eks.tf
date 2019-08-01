# vpc networking settings
data "aws_region" "ap-northeast-2" {}

data "aws_availability_zones" "available" {}

resource "aws_vpc" "aws-prototype" {
  cidr_block = "10.0.0.0/16"

  tags = "${
    map(
     "Name", "aws-prototype-node",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_subnet" "aws-prototype" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = "${aws_vpc.aws-prototype.id}"

  tags = "${
    map(
     "Name", "aws-prototype-node",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
     "kubernetes.io/role/elb", 1,
    )
  }"
}

resource "aws_internet_gateway" "aws-prototype" {
  vpc_id = "${aws_vpc.aws-prototype.id}"

  tags = {
    Name = "aws-prototype"
  }
}

resource "aws_route_table" "aws-prototype" {
  vpc_id = "${aws_vpc.aws-prototype.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.aws-prototype.id}"
  }
}

resource "aws_route_table_association" "aws-prototype" {
  count = 2

  subnet_id      = "${aws_subnet.aws-prototype.*.id[count.index]}"
  route_table_id = "${aws_route_table.aws-prototype.id}"
}


# EKS Master Cluster IAM Role
resource "aws_iam_role" "aws-prototype-cluster" {
  name = "aws-prototype-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "aws-prototype-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.aws-prototype-cluster.name}"
}

resource "aws_iam_role_policy_attachment" "aws-prototype-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.aws-prototype-cluster.name}"
}

# EKS Master Cluster Security Group

resource "aws_security_group" "aws-prototype-cluster" {
  name        = "aws-prototype-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${aws_vpc.aws-prototype.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "aws-prototype"
  }
}

resource "aws_security_group_rule" "aws-prototype-cluster-ingress-workstation-https" {
  cidr_blocks       = ["159.153.218.10/32"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.aws-prototype-cluster.id}"
  to_port           = 443
  type              = "ingress"
}

# EKS Master Cluster
resource "aws_eks_cluster" "aws-prototype" {
  name            = "${var.cluster-name}"
  role_arn        = "${aws_iam_role.aws-prototype-cluster.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.aws-prototype-cluster.id}"]
    subnet_ids         = "${aws_subnet.aws-prototype.*.id}"
  }

  depends_on = [
    "aws_iam_role_policy_attachment.aws-prototype-cluster-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.aws-prototype-cluster-AmazonEKSServicePolicy",
  ]
}

# Worker Node IAM Role and Instance Profile
resource "aws_iam_role" "aws-prototype-node" {
  name = "aws-prototype-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "aws-prototype-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.aws-prototype-node.name}"
}

resource "aws_iam_role_policy_attachment" "aws-prototype-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.aws-prototype-node.name}"
}

resource "aws_iam_role_policy_attachment" "aws-prototype-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.aws-prototype-node.name}"
}

resource "aws_iam_instance_profile" "aws-prototype-node" {
  name = "aws-prototype"
  role = "${aws_iam_role.aws-prototype-node.name}"
}

# Worker Node Security Group
resource "aws_security_group" "aws-prototype-node" {
  name        = "aws-prototype-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${aws_vpc.aws-prototype.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
     "Name", "aws-prototype-node",
     "kubernetes.io/cluster/${var.cluster-name}", "owned",
    )
  }"
}

resource "aws_security_group_rule" "aws-prototype-node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.aws-prototype-node.id}"
  source_security_group_id = "${aws_security_group.aws-prototype-node.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "aws-prototype-node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.aws-prototype-node.id}"
  source_security_group_id = "${aws_security_group.aws-prototype-cluster.id}"
  to_port                  = 65535
  type                     = "ingress"
}

# Worker Node Access to EKS Master Cluster
resource "aws_security_group_rule" "aws-prototype-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.aws-prototype-cluster.id}"
  source_security_group_id = "${aws_security_group.aws-prototype-node.id}"
  to_port                  = 443
  type                     = "ingress"
}

# Worker Node AutoScaling Group
data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.aws-prototype.version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We implement a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
locals {
  aws-prototype-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.aws-prototype.endpoint}' --b64-cluster-ca '${aws_eks_cluster.aws-prototype.certificate_authority.0.data}' '${var.cluster-name}'
USERDATA
}

resource "aws_launch_configuration" "aws-prototype" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.aws-prototype-node.name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "t2.medium"
  name_prefix                 = "aws-prototype"
  security_groups             = ["${aws_security_group.aws-prototype-node.id}"]
  user_data_base64            = "${base64encode(local.aws-prototype-node-userdata)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "aws-prototype" {
  desired_capacity     = 3
  launch_configuration = "${aws_launch_configuration.aws-prototype.id}"
  max_size             = 5
  min_size             = 3
  name                 = "aws-prototype"
  health_check_type    = "ELB"
  force_delete         = true
  vpc_zone_identifier  = "${aws_subnet.aws-prototype.*.id}"

  tag {
    key                 = "Name"
    value               = "aws-prototype"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster-name}"
    value               = "owned"
    propagate_at_launch = true
  }
}