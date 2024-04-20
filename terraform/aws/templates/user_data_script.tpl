#!/bin/bash

set -eu

apt-get update -y
apt-get install -y docker.io docker-compose ec2-instance-connect

# Check if Docker is installed
if ! which docker > /dev/null; then
  echo "Docker is not installed. Exiting."
  exit 1
fi

# Check if Docker Compose is installed
if ! which docker-compose > /dev/null; then
  echo "Docker Compose is not installed. Exiting."
  exit 1
fi

# Wait for the EBS volume to be attached
while [ ! -e /dev/xvdh ]
do
  echo "Waiting for EBS volume /dev/xvdh to attach"
  sleep 5
done

# Format and mount the EBS volume
mkfs.ext4 /dev/xvdh
mkdir -p /mnt/sftpgo
mount /dev/xvdh /mnt/sftpgo
echo '/dev/xvdh /mnt/sftpgo ext4 defaults,nofail 0 2' >> /etc/fstab
chown ubuntu:ubuntu /mnt/sftpgo

mkdir -p /letsencrypt /mnt/sftpgo/data /mnt/sftpgo/config /letsencrypt
chown ubuntu:ubuntu /letsencrypt /mnt/sftpgo/data /mnt/sftpgo/config

systemctl start docker
systemctl enable docker

# Traefik Configuration
cat > /letsencrypt/traefik.yaml <<EOF
[entryPoints]
  [entryPoints.web]
    address = ":80"
  [entryPoints.websecure]
    address = ":443"

[certificatesResolvers.letsencrypt.acme]
  email = "devops@jsoh.io"
  storage = "/letsencrypt/acme.json"
  [certificatesResolvers.letsencrypt.acme.httpChallenge]
    entryPoint = "web"

[providers.docker]
  exposedByDefault = false

[log]
  level = "INFO"

[accessLog]
EOF
touch /letsencrypt/acme.json
chmod 600 /letsencrypt/acme.json

# https://github.com/drakkan/sftpgo/blob/main/sftpgo.json
cat > /mnt/sftpgo/sftpgo.json <<EOF
{
  "data_provider": {
    "driver": "postgresql",
    "name": "${sftpgo_db_name}",
    "host": "${sftpgo_db_host}",
    "port": 5432,
    "username": "${sftpgo_db_user}",
    "password": "${sftpgo_db_pass}",
    "password_caching": true,
    "create_default_admin": false
  },
  "s3": {
    "bucket": "${aws_s3_bucket_name}",
    "region": "${aws_s3_region}",
    "credentials": {
      "access_key_id": "",
      "access_secret_key": "",
      "access_token": ""
    }
  }
}
EOF

cat > /mnt/sftpgo/docker-compose.yaml <<EOF
version: "3.3"

services:

  traefik:
    image: "traefik:v2.10"
    container_name: "traefik"
    command:
      - "--api=true"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.letsencrypt.acme.email=devops@jsoh.io"
      - "--certificatesresolvers.letsencrypt.acme.dnschallenge=true"
      - "--certificatesresolvers.letsencrypt.acme.dnschallenge.provider=cloudflare"
      - "--certificatesresolvers.letsencrypt.acme.dnschallenge.delaybeforecheck=0"
      - "--certificatesresolvers.letsencrypt.acme.dnschallenge.resolvers=1.1.1.1:53,8.8.8.8:53"
      - "--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json"
      # UNCOMMENT OUT THE FOLLOWING LINES FOR TESTING
      #- "--log.level=DEBUG"
      #- "--certificatesresolvers.letsencrypt.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory"
    environment:
      - CF_DNS_API_TOKEN=${cf_dns_api_token}
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - "/letsencrypt:/letsencrypt"
      - "/var/run/docker.sock:/var/run/docker.sock:ro"
    restart: unless-stopped

  sftpgo:
    image: drakkan/sftpgo:v2.5.6-alpine
    container_name: sftpgo
    ports:
      - "8080:8090"
      - "2022:2022"
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.sftpgo.rule=Host(\`${sftpgo_hostname}\`)"
      - "traefik.http.routers.sftpgo.entrypoints=websecure"
      - "traefik.http.routers.sftpgo.tls.certresolver=letsencrypt"
      - "traefik.http.services.sftpgo.loadbalancer.server.port=8090"
      - "traefik.http.routers.sftpgo-insecure.rule=Host(\`${sftpgo_hostname}\`)"
      - "traefik.http.routers.sftpgo-insecure.entrypoints=web"
      - "traefik.http.middlewares.redirect-to-https.redirectscheme.scheme=https"
      - "traefik.http.routers.sftpgo-insecure.middlewares=redirect-to-https"
    volumes:
      - "/mnt/sftpgo/data:/srv/sftpgo"
      - "/mnt/sftpgo/config:/var/lib/sftpgo"
      - "/mnt/sftpgo/sftpgo.json:/etc/sftpgo/sftpgo.json"
    environment:
      - SFTPGO_HTTPD__BINDINGS__0__PORT=8090
    restart: unless-stopped
EOF

docker-compose -f /mnt/sftpgo/docker-compose.yaml up -d
