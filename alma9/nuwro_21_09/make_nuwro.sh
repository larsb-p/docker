#!/bin/bash

set -e
set -x

NUWRO_VERSION=21_09
NUWRO_VERSION_US=$(echo ${NUWRO_VERSION} | tr "-" "_")

#better to build them sequentially to give the slow/emulated one more cores

docker buildx build . -t lbathepeters/nuwro_${NUWRO_VERSION_US}:alma9-x86_64 \
                       --platform=linux/amd64 \
                       --load --ssh default --build-arg NUWRO_VERSION=${NUWRO_VERSION} --build-arg NCORES=8
docker push lbathepeters/nuwro_${NUWRO_VERSION_US}:alma9-x86_64

docker buildx build . -t lbathepeters/nuwro_${NUWRO_VERSION_US}:alma9-aarch64 \
                        --platform=linux/arm64 \
                        --load --ssh default --build-arg NUWRO_VERSION=${NUWRO_VERSION} --build-arg NCORES=8
docker push lbathepeters/nuwro_${NUWRO_VERSION_US}:alma9-aarch64

docker manifest rm lbathepeters/nuwro_${NUWRO_VERSION_US}:alma9 || true
docker manifest create lbathepeters/nuwro_${NUWRO_VERSION_US}:alma9 \
                --amend lbathepeters/nuwro_${NUWRO_VERSION_US}:alma9-aarch64 \
                --amend lbathepeters/nuwro_${NUWRO_VERSION_US}:alma9-x86_64
docker manifest push lbathepeters/nuwro_${NUWRO_VERSION_US}:alma9
