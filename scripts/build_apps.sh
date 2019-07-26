#!/bin/bash

pushd $PWD

BASEDIR=$(dirname "$0")
cd $BASEDIR

cd ../terraform
LINES=$(terraform output -json)
RDS=$(echo $LINES | jq '.authdb_public_address.value' | tr -d '"')
echo RDS: $RDS

GQL_API_KEY=$(echo $LINES | jq '.graphql_api_key.value' | tr -d '"')
echo GRAPHQL_API_KEY: $GQL_API_KEY

GQL_ENDPOINT=$(echo $LINES | jq '.graphql_api_uris.value.GRAPHQL' | tr -d '"')
echo GRAPHQL_API_URIS: $GQL_URIS

REDIS=$(echo $LINES | jq '.redis_public_address.value' | tr -d '"')
echo REDIS: $REDIS

# Build
cd ../apps
APPS="auth product"
for APP in $APPS; do
    cd $APP
    echo Build $APP..
    docker build -t $APP \
--build-arg GQL_API_KEY=$GQL_API_KEY \
--build-arg GQL_ENDPOINT=$GQL_ENDPOINT \
--build-arg RDS=$RDS \
--build-arg REDIS=$REDIS \
--no-cache .
done;

# ECR
aws ecr get-login --no-include-email --region ap-northeast-2
for APP in $APPS; do
    docker tag $APP:latest 348028092597.dkr.ecr.ap-northeast-2.amazonaws.com/$APP:latest
    docker push 348028092597.dkr.ecr.ap-northeast-2.amazonaws.com/$APP:latest
done;

popd
