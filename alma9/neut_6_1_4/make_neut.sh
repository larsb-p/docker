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

# RECLAIM BETWEEN ARCHITECTURES. The NEUT image is ~9.3GB (it ships the RMF
# tensor tables) and the build additionally needs neut-data checked out, which
# is ~12GB with its git history. Keeping the first architecture on disk while
# the second builds is what makes this fail with "no space left on device",
# which surfaces confusingly as "rpc error: EOF" or ResourceExhausted.
#
# Deleting the local image after pushing is safe: docker manifest create reads
# the per-arch manifests back from the registry, not from local storage.
report_free() {
  echo "### free space: $(df -h / | awk 'NR==2{print $4}') -- $1"
}

report_free "before aarch64"
docker buildx build . -t lbathepeters/neut_${NEUT_VERSION_US}:alma9-aarch64 \
                        --platform=linux/arm64 \
                        --load --ssh default --build-arg NEUT_VERSION=${NEUT_VERSION} --build-arg NCORES=8
docker push lbathepeters/neut_${NEUT_VERSION_US}:alma9-aarch64
docker rmi lbathepeters/neut_${NEUT_VERSION_US}:alma9-aarch64 || true
docker builder prune -f || true
report_free "after aarch64 push+cleanup"

docker buildx build . -t lbathepeters/neut_${NEUT_VERSION_US}:alma9-x86_64 \
                       --platform=linux/amd64 \
                       --load --ssh default --build-arg NEUT_VERSION=${NEUT_VERSION} --build-arg NCORES=8
docker push lbathepeters/neut_${NEUT_VERSION_US}:alma9-x86_64
docker rmi lbathepeters/neut_${NEUT_VERSION_US}:alma9-x86_64 || true
docker builder prune -f || true
report_free "after x86_64 push+cleanup"

docker manifest rm lbathepeters/neut_${NEUT_VERSION_US}:alma9 || true
docker manifest create lbathepeters/neut_${NEUT_VERSION_US}:alma9 \
                --amend lbathepeters/neut_${NEUT_VERSION_US}:alma9-aarch64 \
                --amend lbathepeters/neut_${NEUT_VERSION_US}:alma9-x86_64
docker manifest push lbathepeters/neut_${NEUT_VERSION_US}:alma9
