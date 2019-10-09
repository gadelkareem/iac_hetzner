#!/usr/bin/env bash

set -euo pipefail

COMMON_DIR=$1
. ${COMMON_DIR}/functions.sh


cd "$(dirname "${BASH_SOURCE[0]}")"
PG_CUR_DIR="$(pwd)"

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -sc)-pgdg main" > /etc/apt/sources.list.d/postgresql.list

apt update
apt-get install postgresql-11 -yq

cp "${PG_CUR_DIR}/files/pg_hba.conf" /etc/postgresql/11/main/pg_hba.conf
cp "${PG_CUR_DIR}/files/postgresql.conf" /etc/postgresql/11/main/postgresql.conf

systemctl enable postgresql
systemctl restart postgresql

chown -R postgres: /etc/postgresql/11/main/


#pghero
wget -qO- https://dl.packager.io/srv/pghero/pghero/key | apt-key add -
wget -O /etc/apt/sources.list.d/pghero.list https://dl.packager.io/srv/pghero/pghero/master/installer/ubuntu/$(lsb_release -r -s).repo
sleep 2
apt-get update
apt-get -yq install pghero
pghero config:set DATABASE_URL=postgres://postgres@localhost:5432/app
pghero config:set PORT=3441
pghero scale web=1


cp "${PG_CUR_DIR}/files/postgresql-backup.sh" /root/postgresql-backup.sh

cron "30 6 */1 * * root /usr/bin/flock -w 0 -E 0 /tmp/postgres-backup.lock /root/postgresql-backup.sh > /dev/null" postgresql_backup root
