#!/usr/bin/env bash

set -euo pipefail

ACCESS_KEY=$1
SECRET_KEY=$2
SUB_DOMAIN=$3

mkdir -p /mnt/volume-s3-1/minio /home/minio/certs

cd /etc/letsencrypt/live/${SUB_DOMAIN}
cp fullchain.pem /home/minio/certs/public.crt
cp privkey.pem /home/minio/certs/private.key

stat /home/minio/minio &> /dev/null || curl -sL https://dl.minio.io/server/minio/release/linux-amd64/minio -o /home/minio/minio && \
    chmod +x /home/minio/minio

cat >> /etc/environment <<EOF
MINIO_ACCESS_KEY=${ACCESS_KEY}
MINIO_SECRET_KEY=${SECRET_KEY}
EOF

#minio
#ufw allow 9050 comment "minio"

mkdir -p /mnt/volume-s3-1/minio
adduser --disabled-password --gecos "" minio || true
chown -R minio /mnt/volume-s3-1/minio

