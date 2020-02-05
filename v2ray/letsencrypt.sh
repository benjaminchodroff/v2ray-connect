docker create \
  --name=letsencrypt \
  --cap-add=NET_ADMIN \
  --network connect
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=UTC \
  -e URL="`hostname -d`" \
  -e SUBDOMAINS="`hostname -s`", \
  -e VALIDATION=dns \
  -e DNSPLUGIN=cloudflare `#optional` \
  -e EMAIL="benjamin.chodroff@gmail.com" `#optional` \
  -e DHLEVEL=2048 `#optional` \
  -e ONLY_SUBDOMAINS=true `#optional` \
  -e EXTRA_DOMAINS="" `#optional` \
  -e STAGING=false `#optional` \
  -p 443:443 \
  -p 80:80 `#optional` \
  -v `pwd`/letsencrypt:/config \
  --restart unless-stopped \
  linuxserver/letsencrypt

docker start letsencrypt
