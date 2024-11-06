#!/bin/bash

set -e
set -x

#better to build them sequentially to give the slow/emulated one more cores

#docker buildx build . -t lbathepeters/buildbox:alma9-aarch64 \
#                       --platform=linux/arm64 \
#		       --build-arg NUMC_BUILD_ARCH=aarch64 \
#                       --no-cache \
#		       --push
#
#                       --load --build-arg NUMC_BUILD_ARCH=aarch64 \
#docker push lbathepeters/buildbox:alma9-aarch64

#docker buildx build . -t lbathepeters/buildbox:alma9-x86_64 \
#                       --platform=linux/amd64 \
#                       --load --build-arg NUMC_BUILD_ARCH=x86_64 \
#                       --no-cache
#docker push lbathepeters/buildbox:alma9-x86_64

docker manifest rm lbathepeters/buildbox:alma9 || true
docker manifest create lbathepeters/buildbox:alma9 \
                --amend lbathepeters/buildbox:alma9-aarch64 \
                --amend lbathepeters/buildbox:alma9-x86_64
docker manifest push lbathepeters/buildbox:alma9
