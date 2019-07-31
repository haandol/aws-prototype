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
$ kubectl logs -n kube-system $(kubectl get po -n kube-system | egrep -o "alb-ingress[a-zA-Z0-9-]+")
