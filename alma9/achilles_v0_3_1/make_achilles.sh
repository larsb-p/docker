#!/bin/bash

set -e
set -x

ACHILLES_VERSION=v0.3.1
ACHILLES_VERSION_US=$(echo ${ACHILLES_VERSION} | sed "s/^v//" | tr "." "_")

# No --ssh here: Achilles and all of its CPM dependencies are public.

#better to build them sequentially to give the slow/emulated one more cores

docker buildx build . -t lbathepeters/achilles_${ACHILLES_VERSION_US}:alma9-x86_64 \
                       --platform=linux/amd64 \
                       --load --build-arg ACHILLES_VERSION=${ACHILLES_VERSION} --build-arg NCORES=8
docker push lbathepeters/achilles_${ACHILLES_VERSION_US}:alma9-x86_64

docker buildx build . -t lbathepeters/achilles_${ACHILLES_VERSION_US}:alma9-aarch64 \
                        --platform=linux/arm64 \
                        --load --build-arg ACHILLES_VERSION=${ACHILLES_VERSION} --build-arg NCORES=8
docker push lbathepeters/achilles_${ACHILLES_VERSION_US}:alma9-aarch64

docker manifest rm lbathepeters/achilles_${ACHILLES_VERSION_US}:alma9 || true
docker manifest create lbathepeters/achilles_${ACHILLES_VERSION_US}:alma9 \
                --amend lbathepeters/achilles_${ACHILLES_VERSION_US}:alma9-aarch64 \
                --amend lbathepeters/achilles_${ACHILLES_VERSION_US}:alma9-x86_64
docker manifest push lbathepeters/achilles_${ACHILLES_VERSION_US}:alma9
