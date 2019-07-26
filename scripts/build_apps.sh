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
    cd ..
done;

popd
