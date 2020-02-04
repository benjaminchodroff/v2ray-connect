#!/bin/bash
docker stop v2ray
docker stop docker-nginx
docker rm v2ray
docker rm docker-nginx
rm key.pem cert.pem config.json clashx.yaml shadowrocket.json
