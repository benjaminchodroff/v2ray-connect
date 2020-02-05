#!/bin/bash
## This will install v2ray in a docker container on an
## Ubuntu 16.0.4 LTS server
## This is a basic configuration of v2ray that includes:
## VMESS+TLS+WS+CDN support (CloudFlare) and User statistics
## Example ClashX (MacOS) and Shadowrocket (iOS) provided

# https://tools.sprov.xyz/v2ray/
# https://hub.docker.com/r/teddysun/v2ray/

bash <(curl -L -s https://install.direct/go.sh)

apt update
apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt-get update
apt-get -y install docker-ce docker-ce-cli containerd.io
apt-get -y install git pwgen sendmail vim telnet jq
if test -f "/swapfile"; then
    echo "Swap exists, skipping swap setup"
else
    fallocate -l 4G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
    mount -a
    echo 'vm.swappiness=10' | tee -a /etc/sysctl.conf
    echo 'vm.vfs_cache_pressure = 50' | tee -a /etc/sysctl.conf
fi
sysctl -p
apt -y upgrade
apt -y autoremove 

docker network create connect
if test -f "letsencrypt/keys/cert.key"; then
    echo "Existing key found, skipping regeneration"
else
    mkdir letsencrypt
    ./letsencrypt.sh
fi
cp -f nginx.template letsencrypt/nginx/site-confs/default
cp -f index.html.template letsencrypt/www/index.html

if test -f "config.json"; then
    echo "Existing config found, skipping regeneration"
else
    echo "Generating a new v2ray and client configurations"
    UUID1="`uuidgen`"
    UUID2="`uuidgen`"
    cp -f config.json.template config.json
    cp -f clashx.yaml.template letsencrypt/www/clashx.yaml
    cp -f shadowrocket.json.template letsencrypt/www/shadowrocket.json
    sed -i 's/UUID1/'$UUID1'/g' config.json letsencrypt/www/clashx.yaml letsencrypt/www/shadowrocket.json
    sed -i 's/UUID2/'$UUID2'/g' config.json letsencrypt/www/clashx.yaml letsencrypt/www/shadowrocket.json
    sed -i 's/SERVER/'`hostname`'/g' config.json letsencrypt/www/clashx.yaml letsencrypt/www/shadowrocket.json
fi
docker stop v2ray
docker rm v2ray

docker pull teddysun/v2ray
docker run -d --network connect -p 10000:10000 -p 8443:8443 -p 8443:8443/udp --name v2ray --restart=always -v `pwd`:/etc/v2ray teddysun/v2ray

