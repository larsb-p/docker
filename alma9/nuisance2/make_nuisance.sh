#!/bin/bash

set -e
set -x

# Builds NUISANCE 2 on top of nugenbox, so nugenbox must already be pushed for
# both architectures before this will work.

#better to build them sequentially to give the slow/emulated one more cores

docker buildx build . -t lbathepeters/nuisance2:alma9-x86_64 \
                       --platform=linux/amd64 \
                       --load --build-arg NCORES=8
docker push lbathepeters/nuisance2:alma9-x86_64

docker buildx build . -t lbathepeters/nuisance2:alma9-aarch64 \
                        --platform=linux/arm64 \
                        --load --build-arg NCORES=8
docker push lbathepeters/nuisance2:alma9-aarch64

docker manifest rm lbathepeters/nuisance2:alma9 || true
docker manifest create lbathepeters/nuisance2:alma9 \
                --amend lbathepeters/nuisance2:alma9-aarch64 \
                --amend lbathepeters/nuisance2:alma9-x86_64
docker manifest push lbathepeters/nuisance2:alma9
