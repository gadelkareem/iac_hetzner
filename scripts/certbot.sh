#!/usr/bin/env bash

set -euo pipefail

apt-get update
# install letsencrypt https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-18-04
add-apt-repository ppa:certbot/certbot -y
apt-get update
apt-get install certbot -yq


