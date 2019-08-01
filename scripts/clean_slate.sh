#!/bin/bash

pushd $PWD

BASEDIR=$(dirname "$0")
cd $BASEDIR

cd ..
for YML in $(find k8s -name *.yml); do
    kubectl delete -f $YML
done;

popd
