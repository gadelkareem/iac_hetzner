#!/usr/bin/env bash

set -euo pipefail


DOMAIN=$1
SUB_DOMAIN=$2
FULL_SUB_DOMAIN="${2}.${1}"
IP=

if [ -n "${3+x}" ]; then
    IP=$3
else
    IP=$(curl -s http://ipv4.icanhazip.com)
fi

echo "Creating SSL certs for ${FULL_SUB_DOMAIN}"
if [ -f /etc/letsencrypt/live/${SUB_DOMAIN}/domain.crt ]; then
    echo "Certificates already generated"
    exit
fi

cat >> /etc/ufw/before.rules <<EOF
-A ufw-before-input -p icmp --icmp-type echo-request -j ACCEPT
EOF
while [[ "${IP}" != $(ping -c1 "${FULL_SUB_DOMAIN}" | sed -nE 's/^PING[^(]+\(([^)]+)\).*/\1/p') ]]; do
    echo "Waiting for DNS to update.."
    sleep 10s
done

ufw allow 80 comment "ssl"
# Generate SSL certificate for SUB_DOMAIN
certbot certonly --standalone --preferred-challenges http --staple-ocsp --non-interactive --agree-tos -m ${SUB_DOMAIN}@${DOMAIN} -d ${FULL_SUB_DOMAIN}
ufw delete allow 80

# Rename SSL certificates
# https://community.letsencrypt.org/t/how-to-get-crt-and-key-files-from-i-just-have-pem-files/7348
cd /etc/letsencrypt/live/${FULL_SUB_DOMAIN} && \
cp privkey.pem domain.key && \
cat cert.pem chain.pem > domain.crt && \
chmod 777 domain.*






