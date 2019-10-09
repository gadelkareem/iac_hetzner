#!/usr/bin/env bash

set -euo pipefail

COMMON_DIR=$1
. ${COMMON_DIR}/functions.sh

cron "30 4 * * 1 app cd ${BASE_PATH} && /usr/bin/flock -w 0 -E 0 /tmp/app-sitemaps.lock ${BASE_PATH}/app -sitemaps > /dev/null" app_sitemaps app

