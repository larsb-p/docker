#!/bin/bash

set -e
set -x

# Composes the per-generator images into one. Nothing is compiled here, so this
# is fast -- but every source image must already be on the hub, for BOTH
# architectures, or the corresponding platform build below will fail to pull.

#better to build them sequentially to give the slow/emulated one more cores

docker buildx build . -t lbathepeters/nugenbox:alma9-x86_64 \
                       --platform=linux/amd64 \
                       --load
docker push lbathepeters/nugenbox:alma9-x86_64

docker buildx build . -t lbathepeters/nugenbox:alma9-aarch64 \
                        --platform=linux/arm64 \
                        --load
docker push lbathepeters/nugenbox:alma9-aarch64

docker manifest rm lbathepeters/nugenbox:alma9 || true
docker manifest create lbathepeters/nugenbox:alma9 \
                --amend lbathepeters/nugenbox:alma9-aarch64 \
                --amend lbathepeters/nugenbox:alma9-x86_64
docker manifest push lbathepeters/nugenbox:alma9
