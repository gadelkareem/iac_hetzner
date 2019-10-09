#!/usr/bin/env bash

set -euo pipefail


BASE_PATH=/var/www/application
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
CRON_HEADER="SHELL=/bin/sh \n
PATH=${PATH}

"
export PATH=${PATH}

function cron(){
    echo -e ${CRON_HEADER} > /etc/cron.d/${2}
    echo -e ${1} >> /etc/cron.d/${2}
    chown ${3}: /etc/cron.d/${2}
}

function run(){
    eval "${1} > /dev/null 2>&1" && echo 0 || echo 1
}

function wait_for(){
    for i in {1..60}; do $(eval "${1}") && break || sleep 5; done
    eval "${1}"
}


