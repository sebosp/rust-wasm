#!/bin/bash

docker pull $APP_NAME:$RUST_VERSION 2> /dev/null
docker build -t $APP_NAME:$RUST_VERSION .
docker push $APP_NAME:$RUST_VERSION
