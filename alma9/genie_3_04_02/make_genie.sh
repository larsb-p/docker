#!/bin/bash

set -e
set -x

GENIE_VERSION=3_04_02

#better to build them sequentially to give the slow/emulated one more cores

docker buildx build . -t lbathepeters/genie_${GENIE_VERSION}:alma9-x86_64 \
                       --platform=linux/amd64 \
                       --load --ssh default --build-arg GENIE_VERSION=${GENIE_VERSION} --build-arg NCORES=8
docker push lbathepeters/genie_${GENIE_VERSION}:alma9-x86_64

docker buildx build . -t lbathepeters/genie_${GENIE_VERSION}:alma9-aarch64 \
#docker buildx build . --no-cache -t lbathepeters/genie_${GENIE_VERSION}:alma9-aarch64 \
                        --platform=linux/arm64 \
                        --load --ssh default --build-arg GENIE_VERSION=${GENIE_VERSION} --build-arg NCORES=8
docker push lbathepeters/genie_${GENIE_VERSION}:alma9-aarch64

docker manifest rm lbathepeters/genie_${GENIE_VERSION}:alma9 || true
docker manifest create lbathepeters/genie_${GENIE_VERSION}:alma9 \
                --amend lbathepeters/genie_${GENIE_VERSION}:alma9-aarch64 \
                --amend lbathepeters/genie_${GENIE_VERSION}:alma9-x86_64
docker manifest push lbathepeters/genie_${GENIE_VERSION}:alma9
