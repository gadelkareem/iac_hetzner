#!/usr/bin/env bash

set -euo pipefail

DIRECTION=$1

cd "$(dirname "${BASH_SOURCE[0]}")"
CUR_DIR="$(pwd)"
export HCLOUD_TOKEN=$(jq -r .hcloud_token vars.json)

###release number
RELEASE=$(jq -r .release vars.json)

function pack(){
    RESULT=$(hcloud image list --selector "${2}=${3}")
    if [[ "${RESULT}" != *"${3}"* ]] ; then
        echo
        echo "Building ${1} snapshot..."
        packer build -var-file vars.json "packer/${1}.json" # -on-error=abort
    fi
}
function img_id(){
    hcloud image list --selector "${1}" --output noheader --output columns=ID
}

export RELEASE=${RELEASE}

echo
echo "Going ${DIRECTION}.."
if [[ "${DIRECTION}" == "up" ]]; then
    pack "base" "name" "base_${RELEASE}"
    export BASE_IMG_ID=$(img_id "name=base_${RELEASE}")

    pack "s3" "name" "s3_${RELEASE}" & A=$!
    pack "app" "name" "app_${RELEASE}" & B=$!
    pack "db" "name" "db_${RELEASE}" & C=$!
    wait $A
    wait $B
    wait $C

    terraform init -input=false -var-file vars.json terraform/ > /dev/null
    #terraform plan  -var-file vars.json terraform/
    terraform apply -input=false -auto-approve -var-file vars.json terraform/

    #adjust UFW to allow traffic between instances
    sup -f supfile/config.yml hetzner ufw
fi

if [[ "${DIRECTION}" == "down" ]]; then
    ##teardown
    read -p "Destroy infrastructure (y/n)?" X &&  [[ "${X}" == "y" ]] && \
        terraform destroy  -input=false -auto-approve --var-file vars.json terraform/
    read -p "Delete snapshots (y/n)?" X &&  [[ "${X}" == "y" ]] && \
        for i in $(img_id "release=${RELEASE}"); do hcloud image delete $i; done
fi







