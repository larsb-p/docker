#!/bin/bash

set -e
set -x

GENIE_VERSION=3_06_02

# RUN ONLY ONE make_*.sh AT A TIME. Two of these in parallel is what exhausts
# the disk; the failure surfaces as "ResourceExhausted ... metadata_v2.db: no
# space left on device", or confusingly as "rpc error: EOF".
#
# aarch64 first (native on Apple Silicon, amd64 is emulated and much slower), and
# the local image is deleted after each push so the second architecture starts
# with a clean disk. That is safe: docker manifest create reads the per-arch
# manifests back from the registry, not from local storage.
report_free() {
  echo "### free space: $(df -h / | awk 'NR==2{print $4}') -- $1"
}

report_free "before aarch64"
docker buildx build . -t lbathepeters/genie_${GENIE_VERSION}:alma9-aarch64 \
                        --platform=linux/arm64 \
                        --load --build-arg GENIE_VERSION=${GENIE_VERSION} --build-arg NCORES=8
docker push lbathepeters/genie_${GENIE_VERSION}:alma9-aarch64
docker rmi lbathepeters/genie_${GENIE_VERSION}:alma9-aarch64 || true
docker builder prune -f || true
report_free "after aarch64 push+cleanup"

docker buildx build . -t lbathepeters/genie_${GENIE_VERSION}:alma9-x86_64 \
                       --platform=linux/amd64 \
                       --load --build-arg GENIE_VERSION=${GENIE_VERSION} --build-arg NCORES=8
docker push lbathepeters/genie_${GENIE_VERSION}:alma9-x86_64
docker rmi lbathepeters/genie_${GENIE_VERSION}:alma9-x86_64 || true
docker builder prune -f || true
report_free "after x86_64 push+cleanup"

docker manifest rm lbathepeters/genie_${GENIE_VERSION}:alma9 || true
docker manifest create lbathepeters/genie_${GENIE_VERSION}:alma9 \
                --amend lbathepeters/genie_${GENIE_VERSION}:alma9-aarch64 \
                --amend lbathepeters/genie_${GENIE_VERSION}:alma9-x86_64
docker manifest push lbathepeters/genie_${GENIE_VERSION}:alma9
