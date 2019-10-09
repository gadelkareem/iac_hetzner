#!/usr/bin/env bash

set -euo pipefail


ID=$1
NAME=$2

if [[ $(mount | grep -c "/mnt/${NAME}") == 1 ]]; then
    echo "Volume is already mounted"
    exit
fi

mkfs.ext4 -F /dev/disk/by-id/scsi-0HC_Volume_${ID}
mkdir -p /mnt/${NAME}
mount -o discard,defaults /dev/disk/by-id/scsi-0HC_Volume_${ID} /mnt/${NAME}

