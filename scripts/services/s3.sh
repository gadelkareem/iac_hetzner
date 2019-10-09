#!/usr/bin/env bash

set -euo pipefail

COMMON_DIR=$1
. ${COMMON_DIR}/functions.sh
SUB_DOMAIN=$2


# Setup letsencrypt certificates renewing
cron "30 2 * * 1 root ufw allow 80 && /usr/bin/certbot renew >> /var/log/letsencrypt-renew.log && cd /etc/letsencrypt/live/${SUB_DOMAIN} && cp fullchain.pem /home/minio/public.crt && cp privkey.pem /home/minio/private.key && ufw delete allow 80 && chown -R minio: /home/minio" letencrypt root





