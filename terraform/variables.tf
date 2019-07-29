variable "cluster-name" {
  type = "string"
  default = "aws-prototype"
}

locals {
  config_map = <<CONFIGMAP


apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: default
data:
  AWS_APPSYNC_GRAPHQL_ENDPOINT: ${aws_appsync_graphql_api.product_graphql_api.uris.GRAPHQL}
  AWS_APPSYNC_APIKEY: ${aws_appsync_api_key.product_api_key.key}
  PG_HOST: ${aws_db_instance.authdb.address}
CONFIGMAP
}

locals {
  kubeconfig = <<KUBECONFIG


apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.aws-prototype.endpoint}
    certificate-authority-data: ${aws_eks_cluster.aws-prototype.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${var.cluster-name}"
KUBECONFIG
}

locals {
  config_map_aws_auth = <<CONFIGMAPAWSAUTH


apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.aws-prototype-node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH
}

locals {
  alb_deployment = <<ALBDEPLOYMENT


apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/name: alb-ingress-controller
  name: alb-ingress-controller
  namespace: kube-system
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: alb-ingress-controller
  template:
    metadata:
      labels:
        app.kubernetes.io/name: alb-ingress-controller
    spec:
      containers:
        - name: alb-ingress-controller
          args:
            - --ingress-class=alb
            - --cluster-name=${var.cluster-name}
            - --aws-vpc-id=${aws_vpc.aws-prototype.id}
            - --aws-region=ap-northeast-2
          env:
            - name: AWS_ACCESS_KEY_ID
              value: AKIAVCCAXIC26KDKM7PJ
            - name: AWS_SECRET_ACCESS_KEY
              value: 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
          image: docker.io/amazon/aws-alb-ingress-controller:v1.1.2
          resources:
            limits:
              memory: "128Mi"
              cpu: "500m"
      serviceAccountName: alb-ingress-controller
ALBDEPLOYMENT
}