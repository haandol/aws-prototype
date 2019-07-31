#!/bin/bash

pushd $PWD

BASEDIR=$(dirname "$0")
cd $BASEDIR

cd ../terraform
terraform output kubeconfig > ~/.kube/config
terraform output aws_auth_configmap > ../k8s/aws_auth_configmap.yml
terraform output app_configmap > ../k8s/app_configmap.yml
terraform output alb_deployment > ../k8s/alb_deployment.yml

popd