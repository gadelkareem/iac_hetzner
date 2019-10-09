#!/usr/bin/env bash

set -euo pipefail

cd `dirname $0`

TIMESTAMP=$(date '+%Y_%m_%d__%H_%M_%S')
ENV=prod

mkdir -p /var/backups/databases
cd /var/backups/databases

function backup(){
    DB=${1}
    FILENAME=${TIMESTAMP}.dump
    ROUTE="${DB}/${ENV}"
    DIR=/var/backups/databases/${ROUTE}
    FILE="${DIR}/${FILENAME}"

    mkdir -p "${DIR}"
    cd "${DIR}"

    echo Backing up ${DB}

    if [ "${DB}" == "all" ]; then
        FILE="${FILE}.bz2"
        pg_dumpall -U postgres -h localhost --no-password | bzip2 > ${FILE}
    else
        pg_dump -U postgres --no-owner --no-acl -h localhost -f ${FILE}  --format=custom --compress=9 --no-password ${DB}
    fi

    echo Uploading ${DB}
    /usr/bin/s3cmd get ${FILE} s3://db.backups/${ROUTE}/${FILENAME}
    rm -f ${FILE}

    echo "s3://db.backups/${ROUTE}/${FILENAME}" > latest
    /usr/bin/s3cmd get latest "s3://db.backups/${ROUTE}/latest"
    rm -f latest
}

function restore(){
    DB=${1}
    ROUTE="${DB}/${ENV}"
    DIR=/var/backups/databases/${ROUTE}

    mkdir -p "${DIR}"
    cd "${DIR}"

    /usr/bin/s3cmd get --force s3://db.backups/${ROUTE}/latest
    /usr/bin/s3cmd get --force $(cat latest) - > latest.dump

    if [ "${DB}" == "all" ]; then
        bzcat latest.dump | psql -U postgres postgres
    else
        pg_restore -v --jobs=4 -U postgres --no-owner -d ${DB} latest.dump
    fi

    rm -f latest
    rm -f latest.dump
}


for i in "${@:2}"
do
    $1 $i
done

