#!/usr/bin/env bash

function getOsType() {
  # Detect the platform (similar to $OSTYPE)
  local osType
  local dockerSock
  osType="$(uname)"
  case "${osType}" in
    'Linux')
      dockerSock="true"
      ;;
    'Darwin')
      dockerSock="false"
      ;;
    *) ;;
  esac
  echo "${dockerSock}"
}
function setKeyBaseVars() {
  local kTeam
  local kTeamSubDir
  if [ "$1" = "team" ];then
    kTeam=${KEYBASE_TEAM:-""}
    echo "${kTeam}"
  fi
  if [ "$1" = "subdir" ];then
    kTeamSubDir=${KEYBASE_TEAM_SUBDIR:-""}
    echo "${kTeamSubDir}"
  fi
}
function getGitSha() {
  command -v git > /dev/null 2>&1 || {
    echo >&2 "git is not installed and is required.  Aborting."
    exit 1
  }
  local gitSha
  gitSha=$(git log --pretty=format:'%h' -n 1)
  echo "${gitSha}"
}
function getBuildRef() {
  local buildRef
  buildRef="${CIRCLE_BUILD_NUM}"
  echo "${buildRef}"
}

function installSemVer() {
  local REPODIR
  REPODIR=$(pwd)
  local binDir
  binDir="${_BINDIR:-./bin}"
  local tmpDir
  tmpDir="${_TMPDIR:-/tmp}"
  mkdir -p "${binDir}"
  export PATH=$PATH:${REPODIR}/bin
  if ! [ -x "$(command -v wget)" ] || ! [ -x "$(command -v unzip)" ]; then
    echo "unzip and wget are required please install"
  fi
  if ! [ -x "$(command -v semver.sh)" ] || ! [ -x "$(command -v bump.sh)" ]; then
    cd "${tmpDir}" || exit 1
    wget https://github.com/miguelaferreira/semver_bash/archive/master.zip
    unzip master.zip
    cd semver_bash-master || exit 1
    mv semver.sh bump.sh ${REPODIR}/bin
    cd "${tmpDir}" || exit 1
    rm -rf ./master.zip ./semver_bash-master
    cd "${REPODIR}" || echo "Unable to get back to RepoDir ${REPODIR}"
  fi
}
function buildImage() {
  if [ -x "ci/build.sh" ]; then
    ci/build.sh
  fi
}
function testImage() {
  if [ -x "ci/test.sh" ]; then
    ci/test.sh
  fi
}
function publishContainer() {
  if [ -x "ci/publish-container.sh" ] && [ -x "ci/release.sh" ]; then
    ci/publish-container.sh
    ci/release.sh
  else
    echo "CI scripts not available for publishing."
  fi
}
function writeAllVars () {
  echo "gitSha=${gitSha}" > .env
  echo "buildRef=${buildRef}" >> .env
  echo "keybase_BUILD=${keybase_BUILD}" >> .env
  echo "keybase_TEST=${keybase_TEST}" >> .env
  echo "keybase_RELEASE=${keybase_RELEASE}" >> .env
  echo "CONTAINER_TEST_IMAGE=${CONTAINER_TEST_IMAGE}" >> .env
  echo "CONTAINER_RELEASE_IMAGE=${CONTAINER_RELEASE_IMAGE}" >> .env
  echo "CONTAINER_NAME=${CONTAINER_NAME}" >> .env
  echo "dockerSock=${dockerSock}" >> .env
  echo "KEYBASE_TEAM=${KEYBASE_TEAM}" >> .env
  echo "KEYBASE_TEAM_SUBDIR=${KEYBASE_TEAM_SUBDIR}" >> .env
}

gitSha=$(getGitSha)
buildRef=$(getBuildRef)
keybase_BUILD=${keybase_BUILD:-true}
keybase_TEST=${keybase_TEST:-true}
keybase_RELEASE=${keybase_RELEASE:-true}
CONTAINER_TEST_IMAGE="unifio/keybase:alpine-${gitSha:-test}"
CONTAINER_RELEASE_IMAGE="unifio/keybase"
CONTAINER_NAME="test_container_${buildRef:-local}"
dockerSock=$(getOsType)
KEYBASE_TEAM=$(setKeyBaseVars "team")
KEYBASE_TEAM_SUBDIR=$(setKeyBaseVars "subdir")

writeAllVars
cat .env
docker login  -u $DOCKER_USER -p "$DOCKER_PASS"

set -xv

if [ "${keybase_BUILD}" = "true" ]; then
  buildImage
fi
if [ "${keybase_TEST}" = "true" ]; then
  testImage
fi

if [ "${keybase_RELEASE}" = "true" ]; then
  installSemVer
  publishContainer
fi
rm .env
echo "Completed"
