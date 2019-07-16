#!/usr/bin/env bash

KBD=$1

if [[ -z "${KBD}" ]]; then
    echo "==# umount_kbfs should be called with the path to the directory where you wrote the last file."
    exit 1
fi

while [[ $(  cd "${KBD}" && cat .kbfs_status | jq '.DirtyPaths == null' ) == "false" ]];
do
    echo "==> Wait for flush"
    sleep 1
done
