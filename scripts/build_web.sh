#!/bin/bash

pushd $PWD

BASEDIR=$(dirname "$0")
cd $BASEDIR

# Build
cd ../web
echo Build web..
docker build -t web:latest --no-cache .

# ECR
aws ecr get-login --no-include-email --region ap-northeast-2
docker tag web:latest 348028092597.dkr.ecr.ap-northeast-2.amazonaws.com/web:latest
docker push 348028092597.dkr.ecr.ap-northeast-2.amazonaws.com/web:latest

popd
