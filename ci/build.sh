#!/usr/bin/env bash

set -e

if [[ -f ".env" ]]; then
  source .env
fi

set -v

if [[ -z "${CONTAINER_TEST_IMAGE}" ]]; then
  CONTAINER_TEST_IMAGE=test-image
fi

docker build -t ${CONTAINER_TEST_IMAGE} container
docker push ${CONTAINER_TEST_IMAGE}
