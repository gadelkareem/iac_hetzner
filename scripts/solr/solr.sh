#!/usr/bin/env bash

set -euo pipefail

SOLR_JAVA_MEM="-Xms14g -Xmx15g"
SOLR_HEAP="15g"
LATEST_VER="7.6.0"
SOLR_INSTALL_DIR="/opt/solr"
SOLR_HOME="/var/solr"
JDBC_PSQL_VERSION="42.2.5"

cd "$(dirname "${BASH_SOURCE[0]}")"
SOLR_CUR_DIR="$(pwd)"

if [ ! -f /etc/profile.d/jdk.sh ]; then
    source /etc/profile.d/jdk.sh
fi

if [ ! -d ${SOLR_INSTALL_DIR} ]; then
    curl -O https://www-eu.apache.org/dist/lucene/solr/${LATEST_VER}/solr-${LATEST_VER}.tgz
    tar xf solr-${LATEST_VER}.tgz
    cd solr-${LATEST_VER}/bin/
    ./install_solr_service.sh ${SOLR_CUR_DIR}/solr-${LATEST_VER}.tgz
fi


cat >> /etc/default/solr.in.sh <<EOF
SOLR_HEAP="${SOLR_HEAP}"
SOLR_JAVA_MEM="${SOLR_JAVA_MEM}"
SOLR_OPTS="\$SOLR_OPTS -Dsolr.database.host=\${SOLR_DB_HOST} -Dsolr.database.password=\${SOLR_DB_PASSWORD}"
EOF
service solr stop
rm -f /etc/init.d/solr

SERVICE_PATH=/lib/systemd/system/solr.service
cat > ${SERVICE_PATH} <<EOF
[Unit]
Description=Apache SOLR
ConditionPathExists=${SOLR_INSTALL_DIR}
After=syslog.target network.target remote-fs.target nss-lookup.target systemd-journald-dev-log.socket
Before=multi-user.target
Conflicts=shutdown.target

[Service]
User=solr
LimitNOFILE=1048576
LimitNPROC=1048576
PIDFile=/var/solr/solr-8983.pid
Environment=SOLR_INCLUDE=/etc/default/solr.in.sh
Environment=RUNAS=solr
Environment=SOLR_INSTALL_DIR=${SOLR_INSTALL_DIR}

Restart=on-failure
RestartSec=5
startLimitIntervalSec=60

ExecStart=${SOLR_INSTALL_DIR}/bin/solr start
ExecStop=${SOLR_INSTALL_DIR}/bin/solr stop
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
chown solr: ${SERVICE_PATH}
chmod 0755 ${SERVICE_PATH}
systemctl daemon-reload
systemctl enable solr.service
#systemctl start solr.service


mkdir /opt/solr/contrib/dataimporthandler/lib
wget -O /opt/solr/contrib/dataimporthandler/lib/postgresql-${JDBC_PSQL_VERSION}.jar "http://jdbc.postgresql.org/download/postgresql-${JDBC_PSQL_VERSION}.jar"


su solr -c "${SOLR_INSTALL_DIR}/bin/solr delete -c collection1 && ${SOLR_INSTALL_DIR}/bin/solr delete -c test"
su solr -c "${SOLR_INSTALL_DIR}/bin/solr create_core -c app"

cp "${SOLR_CUR_DIR}/files/app/*" ${SOLR_HOME}/data/app/conf/



