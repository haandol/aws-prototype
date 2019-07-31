#!/bin/bash

pushd $PWD

BASEDIR=$(dirname "$0")
cd $BASEDIR

cd ../k8s
kubectl apply -f aws_auth_configmap.yml
kubectl apply -f service.yml
kubectl apply -f app_configmap.yml
kubectl apply -f rbac-role.yml
kubectl apply -f alb_deployment.yml
kubectl apply -f ingress.yml
kubectl apply -f external-dns.yml

popd