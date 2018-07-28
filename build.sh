#!/bin/bash

if [[ -z $APP_NAME ]] || [[ -z $RUST_VERSION ]]; then
  >&2 echo "Missing APP_NAME and RUST_VERSION"
  exit 1
fi
docker pull $APP_NAME:$RUST_VERSION 2> /dev/null
docker build -t $APP_NAME:$RUST_VERSION .
docker push $APP_NAME:$RUST_VERSION
