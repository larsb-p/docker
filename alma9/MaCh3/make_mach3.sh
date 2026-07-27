#!/bin/bash

set -e
set -x

MACH3_VERSION=1.2.0

# SSH Agent Forwarding
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

#better to build them sequentially to give the slow/emulated one more cores

#docker buildx build . -t lbathepeters/mach3_${MACH3_VERSION}:alma9-x86_64 \
#                       --platform=linux/amd64 \
#                       --load --ssh default --build-arg MACH3_VERSION=${MACH3_VERSION} --build-arg NCORES=8
#docker push lbathepeters/mach3_${MACH3_VERSION}:alma9-x86_64

#docker buildx build . -t lbathepeters/mach3_${MACH3_VERSION}:alma9-aarch64 \
#                        --platform=linux/arm64 \
#                        --load --ssh default --build-arg MACH3_VERSION=${MACH3_VERSION} --build-arg NCORES=8
#docker push lbathepeters/mach3_${MACH3_VERSION}:alma9-aarch64

docker manifest rm lbathepeters/mach3_${MACH3_VERSION}:alma9 || true
docker manifest create lbathepeters/mach3_${MACH3_VERSION}:alma9 \
                --amend lbathepeters/mach3_${MACH3_VERSION}:alma9-aarch64 \
                --amend lbathepeters/mach3_${MACH3_VERSION}:alma9-x86_64
docker manifest push lbathepeters/mach3_${MACH3_VERSION}:alma9
