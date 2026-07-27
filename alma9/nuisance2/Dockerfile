# syntax=docker/dockerfile:1
#
# NUISANCE 2, built ON TOP OF nugenbox so it can link against the generators.
#
# WHY A PINNED COMMIT RATHER THAN A TAG:
# NUISANCE 2's release tags are abandoned -- the newest, v2r8, is from
# 2017-09-02 ("freeze state before Utils functions"), while main is actively
# developed and had commits in 2026-06. Pinning to "the latest tag" would ship
# nine-year-old code. Luke's image is called nuisance2_git_master for exactly
# this reason. Pinning the SHA below keeps the build reproducible while still
# being current; bump it deliberately when you want newer code.
#
# NUISANCE 3 was considered and rejected: it has NO tags at all and its last
# commit (2025-06-19) is a YEAR OLDER than NUISANCE 2's. It is the newer
# codebase but not the more current one.
#
# WHY FROM nugenbox:
# NUISANCE links directly against the generator libraries -- the CMake switches
# below are GENIE_ENABLED / NEUT_ENABLED / NuWro_ENABLED -- so it cannot be
# built against nugen_env, which has ROOT and LHAPDF but no generators. This
# mirrors upstream, where nuisance2_git_master builds FROM picker24/genbox.

ARG NUGENBOX_IMAGE=lbathepeters/nugenbox:alma9

# Pinned head of main as of 2026-06-02:
#   "now hopefully always communicates the NEUT version to the CPP directive"
ARG NUISANCE_COMMIT=f5f79db6c7b80b496e249f938982d43291f91de7
ARG NCORES=4

FROM ${NUGENBOX_IMAGE} AS nuisance_build
ARG NUISANCE_COMMIT
ARG NCORES
WORKDIR /opt

RUN git clone https://github.com/NUISANCEMC/nuisance.git nuisance-src \
 && cd nuisance-src \
 && git checkout ${NUISANCE_COMMIT} \
 && git rev-parse --short HEAD > /opt/nuisance-src/git.shorthash

WORKDIR /opt/nuisance-build
# The generator switches are read from the environment nugenbox already sets
# (GENIE, NEUT_ROOT, NUWRO), so they do not need repeating here.
#
# NOTE: GiBUU and Achilles deliberately have no switch. NUISANCE 2 does not link
# their APIs; it consumes GiBUU's stdhep output and Achilles' NuHepMC output as
# files, which is what NuHepMC_ENABLED covers.
RUN cmake /opt/nuisance-src \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/opt/nuisance/2 \
      -DGENIE_ENABLED=ON \
      -DNEUT_ENABLED=ON \
      -DNuWro_ENABLED=ON \
      -DNuHepMC_ENABLED=ON
RUN make install -j ${NCORES}
RUN cp /opt/nuisance-src/git.shorthash /opt/nuisance/2/


FROM ${NUGENBOX_IMAGE}
WORKDIR /

COPY --from=nuisance_build /opt/nuisance/2 /opt/nuisance/2

ENV NUISANCE=/opt/nuisance/2
ENV PATH=${NUISANCE}/bin:${PATH} \
    LD_LIBRARY_PATH=${NUISANCE}/lib:${NUISANCE}/lib64:${LD_LIBRARY_PATH}

WORKDIR /work
