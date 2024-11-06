#!/bin/bash

set -e
set -x

ROOT_VERSION=v6-30-04
ROOT_VERSION_US=$(echo ${ROOT_VERSION} | tr "-" "_")

#better to build them sequentially to give the slow/emulated one more cores

#docker buildx build . -t lbathepeters/root_${ROOT_VERSION_US}:alma9-x86_64 \
#                       --platform=linux/amd64 \
#                       --load --ssh default --build-arg ROOT_VERSION=${ROOT_VERSION} --build-arg NCORES=8
#docker push lbathepeters/root_${ROOT_VERSION_US}:alma9-x86_64

#docker buildx build . -t lbathepeters/root_${ROOT_VERSION_US}:alma9-aarch64 \
#                        --platform=linux/arm64 \
#                        --load --ssh default --build-arg ROOT_VERSION=${ROOT_VERSION} --build-arg NCORES=8
#docker push lbathepeters/root_${ROOT_VERSION_US}:alma9-aarch64

docker manifest rm lbathepeters/root_${ROOT_VERSION_US}:alma9 || true
docker manifest create lbathepeters/root_${ROOT_VERSION_US}:alma9 \
                --amend lbathepeters/root_${ROOT_VERSION_US}:alma9-aarch64 \
                --amend lbathepeters/root_${ROOT_VERSION_US}:alma9-x86_64
docker manifest push lbathepeters/root_${ROOT_VERSION_US}:alma9
