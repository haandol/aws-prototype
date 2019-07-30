# aws-prototype
aws-prototype

# Installation

Python 3.5.x+
Node 10.16.x+

Install terraform
Install aws-iam-authenticator
Install kubectl

# Config

lambda packing
```
$ ./scripts/zip_lambda.sh
```

run infra
```
$ cd terraform
$ terraform init
$ terraform apply -auto-aprove
```

init rds table
```
$ node apps/auth/scripts/create_tables.js
```

config k8s
```
$ cd terraform
$ terraform output kubeconfig > ~/.kube/config
$ terraform output aws_auth_configmap > ../k8s/aws_auth_configmap.yml
$ terraform output app_configmap > ../k8s/app_configmap.yml
$ terraform output alb_deployment > ../k8s/alb_deployment.yml
```

# Setup EKS Cluster

```
$ cd k8s
$ kubectl apply -f aws_auth_configmap.yml
$ kubectl apply -f service.yml
$ kubectl apply -f app_configmap.yml
$ kubectl apply -f rbac-role.yml
$ kubectl apply -f alb_deployment.yml
$ kubectl apply -f ingress.yml
```

# Run Service

```
$ kubectl apply -f deployment.yml
```

# Test
$ kubectl logs -n kube-system $(kubectl get po -n kube-system | egrep -o "alb-ingress[a-zA-Z0-9-]+")
