#!/bin/sh

set -e

if [[ "${DEBUG_ENTRYPOINT}" = "true" ]]; then
    set -x
fi

if [[ -z "${START_KEYBASE}" ]]; then

    START_KEYBASE="true"

fi

ARG=$1
PATH=$PATH:/go/bin

if [[ -d /keybase ]]; then

  echo "==> Keybase seems to be initialized, skipping"

elif [[ "${START_KEYBASE}" = "true" ]]; then

    if [[ -z "${KEYBASE_PAPERKEY}" || -z "${KEYBASE_USERNAME}" ]]; then

        echo "Please provide the variables KEYBASE_USERNAME and KEYBASE_PAPERKEY."
        echo "if you need to run this without starting Keybase set --env START_KEYBASE=\"false\""
        exit 1

    else

        export KEYBASE_ALLOW_ROOT=1
        export KEYBASE_RUN_MODE=prod

        mkdir /keybase
        mkdir -p /root/.cache/keybase

        keybase oneshot
        sleep 2

        kbfsfuse -debug -log-to-file /keybase &

        # wait for keybase mount point to be ready (at most 30 secs)
        timeout 40 bash -c -- \
          '
           while ! grep "Created new folder-branch" /root/.cache/keybase/keybase.kbfs.log 2> /dev/null; do
             echo "==> Waiting for Keybase file system to be ready"
             sleep 1;
           done
          '

    fi

fi

if [[ -z "${ARG}" ]]; then

  exec /bin/sh

else

  exec "$@"

fi
