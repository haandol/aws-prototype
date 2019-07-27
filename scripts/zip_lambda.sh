#!/bin/bash

pushd $PWD

BASEDIR=$(dirname "$0")
cd $BASEDIR

SHOP="gs"
SERVICES="alarms alarms"

for SERVICE in $SERVICES; do
  cd ../$SERVICE

  if [ ! -d build ]; then
    mkdir build
  fi

  cp $SHOP.py build
  pip install -r requirements.txt -t build

  cd build
  chmod 644 $(find . -type f)
  chmod 755 $(find . -type d)
  zip -r9 ../$SHOP.zip .

  cd ../..
done;

popd
