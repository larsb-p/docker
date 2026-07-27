#!/bin/bash

set -e
set -x

#better to build them sequentially to give the slow/emulated one more cores

#docker buildx build . -t lbathepeters/nugen_env:alma9-x86_64 \
#                       --platform=linux/amd64 \
#                       --load --ssh default --build-arg NCORES=8
#docker push lbathepeters/nugen_env:alma9-x86_64

#docker buildx build . -t lbathepeters/nugen_env:alma9-aarch64 \
#                        --platform=linux/arm64 \
#                        --load --ssh default --build-arg NCORES=8
#docker push lbathepeters/nugen_env:alma9-aarch64

#docker manifest rm lbathepeters/nugen_env:alma9 || true
#docker manifest create lbathepeters/nugen_env:alma9 \
#                --amend lbathepeters/nugen_env:alma9-aarch64 \
#                --amend lbathepeters/nugen_env:alma9-x86_64
docker manifest push lbathepeters/nugen_env:alma9
