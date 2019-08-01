#!/bin/bash

BASEDIR=$(dirname "$0")

SHOP="gs"
SERVICES="crawlers alarms"

for SERVICE in $SERVICES; do
  pushd $PWD

  cd $BASEDIR/../$SERVICE

  rm -rf build
  mkdir build

  cp $SHOP.py build
  pip install -r requirements.txt -t build

  cd build
  chmod 644 $(find . -type f)
  chmod 755 $(find . -type d)
  zip -r9 ../$SHOP.zip .
  chmod 664 ../$SHOP.zip

  popd
done;
