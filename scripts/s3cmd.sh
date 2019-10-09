#!/usr/bin/env bash

set -euo pipefail

ACCESS_KEY=$1
SECRET_KEY=$2
ENDPOINT=$3
LOCATION=$4

apt-get install s3cmd -yq

cat > /root/.s3cfg <<EOF
[default]
# Endpoint
host_base = ${ENDPOINT}
host_bucket = ${ENDPOINT}
bucket_location = ${LOCATION}
use_https = True

# Login credentials
access_key = ${ACCESS_KEY}
secret_key = ${SECRET_KEY}
signature_v2 = False
EOF




