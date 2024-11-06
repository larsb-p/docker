#!/bin/bash

set -e
set -x

SQUIDS_VERSION=v1.3.0

#better to build them sequentially to give the slow/emulated one more cores

docker buildx build . -t lbathepeters/squids_${SQUIDS_VERSION}:alma9-x86_64 \
                       --platform=linux/amd64 \
                       --load --ssh default --build-arg SQUIDS_VERSION=${SQUIDS_VERSION} --build-arg NCORES=8
docker push lbathepeters/squids_${SQUIDS_VERSION}:alma9-x86_64

docker buildx build . -t lbathepeters/squids_${SQUIDS_VERSION}:alma9-aarch64 \
                        --platform=linux/arm64 \
                        --load --ssh default --build-arg SQUIDS_VERSION=${SQUIDS_VERSION} --build-arg NCORES=8
docker push lbathepeters/squids_${SQUIDS_VERSION}:alma9-aarch64

docker manifest rm lbathepeters/squids_${SQUIDS_VERSION}:alma9 || true
docker manifest create lbathepeters/squids_${SQUIDS_VERSION}:alma9 \
                --amend lbathepeters/squids_${SQUIDS_VERSION}:alma9-aarch64 \
                --amend lbathepeters/squids_${SQUIDS_VERSION}:alma9-x86_64
docker manifest push lbathepeters/squids_${SQUIDS_VERSION}:alma9
