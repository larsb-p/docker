#!/bin/bash

set -e
set -x

NEUT_VERSION=6.1.4
NEUT_VERSION_US=$(echo ${NEUT_VERSION} | tr "." "_")

# NEUT is in a PRIVATE repo, and so are its RMF data tables, so --ssh default is
# load-bearing here (unlike make_gibuu.sh). The agent must already hold a key
# with neut-devel access before you run this:
#
#   ssh-add ~/.ssh/id_rsa && ssh-add -l
#
# The ed25519 key on this machine is NOT authorised for neut-devel; the RSA one
# is. An empty agent fails at the clone with "Permission denied (publickey)".
if ! ssh-add -l >/dev/null 2>&1; then
  echo "ERROR: no ssh-agent identities loaded; run 'ssh-add ~/.ssh/id_rsa' first" >&2
  exit 1
fi

#better to build them sequentially to give the slow/emulated one more cores
#
# NOTE: aarch64 FIRST here, unlike the other make_*.sh scripts. On an Apple
# Silicon machine arm64 is native and amd64 runs under QEMU emulation, and this
# build has a very slow early step -- the neut-data clone alone takes 15-20 min
# emulated. Building the native half first means a broken build shows up in
# minutes instead of after the slow one. Swap back if you build on x86 hardware.

docker buildx build . -t lbathepeters/neut_${NEUT_VERSION_US}:alma9-aarch64 \
                        --platform=linux/arm64 \
                        --load --ssh default --build-arg NEUT_VERSION=${NEUT_VERSION} --build-arg NCORES=8
docker push lbathepeters/neut_${NEUT_VERSION_US}:alma9-aarch64

docker buildx build . -t lbathepeters/neut_${NEUT_VERSION_US}:alma9-x86_64 \
                       --platform=linux/amd64 \
                       --load --ssh default --build-arg NEUT_VERSION=${NEUT_VERSION} --build-arg NCORES=8
docker push lbathepeters/neut_${NEUT_VERSION_US}:alma9-x86_64

docker manifest rm lbathepeters/neut_${NEUT_VERSION_US}:alma9 || true
docker manifest create lbathepeters/neut_${NEUT_VERSION_US}:alma9 \
                --amend lbathepeters/neut_${NEUT_VERSION_US}:alma9-aarch64 \
                --amend lbathepeters/neut_${NEUT_VERSION_US}:alma9-x86_64
docker manifest push lbathepeters/neut_${NEUT_VERSION_US}:alma9
