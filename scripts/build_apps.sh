#!/bin/bash

pushd $PWD

BASEDIR=$(dirname "$0")
cd $BASEDIR

# Build
cd ../apps
APPS="auth product"
for APP in $APPS; do
  cd $APP
  echo Build $APP..
  docker build -t $APP:latest --no-cache .
  cd ..
done;

# ECR
eval $(aws ecr get-login --no-include-email --region ap-northeast-2)

for APP in $APPS; do
  docker tag $APP:latest 348028092597.dkr.ecr.ap-northeast-2.amazonaws.com/$APP:latest
  docker push 348028092597.dkr.ecr.ap-northeast-2.amazonaws.com/$APP:latest
done;

popd
