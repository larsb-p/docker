#!/bin/bash

set -e
set -x

GIBUU_VERSION=2025p5

#better to build them sequentially to give the slow/emulated one more cores

# No --ssh here (unlike make_nuwro.sh): GiBUU is fetched over plain https with
# wget, so nothing in the build needs a forwarded agent.

docker buildx build . -t lbathepeters/gibuu_${GIBUU_VERSION}:alma9-x86_64 \
                       --platform=linux/amd64 \
                       --load --build-arg GIBUU_VERSION=${GIBUU_VERSION} --build-arg NCORES=8
docker push lbathepeters/gibuu_${GIBUU_VERSION}:alma9-x86_64

docker buildx build . -t lbathepeters/gibuu_${GIBUU_VERSION}:alma9-aarch64 \
                        --platform=linux/arm64 \
                        --load --build-arg GIBUU_VERSION=${GIBUU_VERSION} --build-arg NCORES=8
docker push lbathepeters/gibuu_${GIBUU_VERSION}:alma9-aarch64

docker manifest rm lbathepeters/gibuu_${GIBUU_VERSION}:alma9 || true
docker manifest create lbathepeters/gibuu_${GIBUU_VERSION}:alma9 \
                --amend lbathepeters/gibuu_${GIBUU_VERSION}:alma9-aarch64 \
                --amend lbathepeters/gibuu_${GIBUU_VERSION}:alma9-x86_64
docker manifest push lbathepeters/gibuu_${GIBUU_VERSION}:alma9
