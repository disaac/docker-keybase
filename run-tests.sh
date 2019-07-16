#!/usr/bin/env bash

set -v
set -e

CONTAINER_NAME="$1"
CONTAINER_TEST_IMAGE="$2"

docker rm -f ${CONTAINER_NAME} 2>&1 > /dev/null || true
if [ "${dockerSock}" = "true" ]; then
  docker run --name ${CONTAINER_NAME} \
  --privileged \
  --device /dev/fuse \
  -e START_KEYBASE="true" \
  -e KEYBASE_USERNAME="${KEYBASE_USERNAME}" \
  -e KEYBASE_PAPERKEY="${KEYBASE_PAPERKEY}" \
  -e KEYBASE_TEAM="${KEYBASE_TEAM}" \
  -e KEYBASE_TEAM_SUBDIR="${KEYBASE_TEAM_SUBDIR}" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -dt ${CONTAINER_TEST_IMAGE}
else
  docker run --name ${CONTAINER_NAME} \
  --privileged \
  --device /dev/fuse \
  -e START_KEYBASE="true" \
  -e KEYBASE_USERNAME="${KEYBASE_USERNAME}" \
  -e KEYBASE_PAPERKEY="${KEYBASE_PAPERKEY}" \
  -e KEYBASE_TEAM="${KEYBASE_TEAM}" \
  -e KEYBASE_TEAM_SUBDIR="${KEYBASE_TEAM_SUBDIR}" \
  -dt ${CONTAINER_TEST_IMAGE}
fi
sleep 30

docker exec -t ${CONTAINER_NAME} ash -c 'timeout 1 ls'
if [ -z "${KEYBASE_TEAM+x}" ] && [ -z "${KEYBASE_TEAM_SUBDIR+x}" ] && [ -n "${KEYBASE_USERNAME+x}" ]; then
  docker exec -t ${CONTAINER_NAME} ash -c 'cat /keybase/private/${KEYBASE_USERNAME}/test.txt'
fi
if [ -n "${KEYBASE_TEAM+x}" ] && [ -n "${KEYBASE_TEAM_SUBDIR+x}" ]; then
  docker exec -t ${CONTAINER_NAME} ash -c 'cat /keybase/team/${KEYBASE_TEAM}/${KEYBASE_TEAM_SUBDIR}/test.txt'
fi
if [ -n "${KEYBASE_TEAM+x}" ] && [ -z "${KEYBASE_TEAM_SUBDIR+x}" ]; then
  docker exec -t ${CONTAINER_NAME} ash -c 'cat /keybase/team/${KEYBASE_TEAM}/test.txt'
fi

# clean up
docker rm -f ${CONTAINER_NAME}
