#!/bin/bash

set -e
set -x

NUOSCILLATOR_VERSION=1.0.2

#better to build them sequentially to give the slow/emulated one more cores

docker buildx build . -t lbathepeters/nuoscillator_${NUOSCILLATOR_VERSION}:alma9-x86_64 \
                       --platform=linux/amd64 \
                       --load --ssh default --build-arg NUOSCILLATOR_VERSION=${NUOSCILLATOR_VERSION} --build-arg NCORES=8
docker push lbathepeters/nuoscillator_${NUOSCILLATOR_VERSION}:alma9-x86_64

docker buildx build . -t lbathepeters/nuoscillator_${NUOSCILLATOR_VERSION}:alma9-aarch64 \
                        --platform=linux/arm64 \
                        --load --ssh default --build-arg NUOSCILLATOR_VERSION=${NUOSCILLATOR_VERSION} --build-arg NCORES=8
docker push lbathepeters/nuoscillator_${NUOSCILLATOR_VERSION}:alma9-aarch64

docker manifest rm lbathepeters/nuoscillator_${NUOSCILLATOR_VERSION}:alma9 || true
docker manifest create lbathepeters/nuoscillator_${NUOSCILLATOR_VERSION}:alma9 \
                --amend lbathepeters/nuoscillator_${NUOSCILLATOR_VERSION}:alma9-aarch64 \
                --amend lbathepeters/nuoscillator_${NUOSCILLATOR_VERSION}:alma9-x86_64
docker manifest push lbathepeters/nuoscillator_${NUOSCILLATOR_VERSION}:alma9
