#!/usr/bin/env bash

set -euo pipefail

export JAVA_VERSION=11.0.1
export DEBIAN_FRONTEND=noninteractive

add-apt-repository ppa:linuxuprising/java -y
apt update
apt-get install oracle-java11-set-default-local -y

cat > /etc/profile.d/jdk.sh <<EOF
export JAVA_HOME=/usr/lib/jvm/jdk-${JAVA_VERSION}
export PATH=\$PATH:\$JAVA_HOME/bin
EOF

