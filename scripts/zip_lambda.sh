#!/bin/bash

pushd $PWD

BASEDIR=$(dirname "$0")
cd $BASEDIR
cd ../crawlers

if [ ! -d "gs" ]; then
  mkdir gs
fi

cp crawler.py gs
pip install -r requirements.txt -t gs

cd gs
zip -r9 ../gs_crawler.zip .

popd
