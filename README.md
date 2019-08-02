# aws-prototype
aws-prototype

# Installation

Python 3.5.x+
Node 10.16.x+

Install terraform
Install aws-iam-authenticator
Install kubectl

# Config

(Optional) modify `provider.tf` because it costs me a lot...

lambda packing
```
$ ./scripts/zip_lambda.sh
```

run infra
```
$ cd terraform
$ terraform init
$ terraform apply -auto-aprove
$ cd ..
```

init rds table
```
$ node apps/auth/scripts/create_tables.js
```

generate k8s yml
```
$ ./scripts/generate_yml.sh
```

# Setup EKS Cluster

```
$ ./scripts/apply_config_yml.sh
```

# Run Service

```
$ kubectl apply -f deployment.yml
```

# Test
```
$ kubectl get ing
$ open www.haandol.com
```

# Destroy resources
```
$ ./scripts/clean_slate.sh
$ cd terraform
$ terraform desctroy -auto-approve
$ cd ..
```

If it failed to destroy vpc, it probably because of the ALB. ALB is created by EKS not terraform which is allocated to VPC and it prevent destroy it.

In that case, you should login to AWS console and delete ALB at EC2 menu and try destroy again, or just delete ALB and VPC which are named `aws-prototype` and call destroy again.
