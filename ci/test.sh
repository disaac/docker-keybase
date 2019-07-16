#!/usr/bin/env bash

set -e

if [[ -f ".env" ]]; then
  source .env
fi

set -v

if [[ -z "${CONTAINER_NAME}" ]]; then
  CONTAINER_NAME="test-container"
fi

if [[ -z "${CONTAINER_TEST_IMAGE}" ]]; then
  CONTAINER_TEST_IMAGE="test-image"
fi

./run-tests.sh "${CONTAINER_NAME}" "${CONTAINER_TEST_IMAGE}"
