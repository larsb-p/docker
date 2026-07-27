# syntax=docker/dockerfile:1
#
# NEUT 6.1.4 (latest stable tag; 6.2.0-RC1/RC2 exist but are release candidates).
#
# NEUT lives in a PRIVATE repo, so the clone needs a forwarded ssh agent:
#   ssh-add ~/.ssh/id_ed25519      # agent must hold a key with neut-devel access
#   docker buildx build --ssh default ...
# Without that the build fails at the clone with a permission-denied.
#
# NEUT 6 is CMake-based (5.x was autotools), and pulls toml11 / FortModGen /
# NucDeEx / NuHepMC / Eigen3 via CPM over public https at configure time, so the
# build stage needs working network but no further credentials.
#
# Built on the ROOT base: find_package(ROOT REQUIRED) is unconditional, and NEUT
# takes its C++ standard from ROOT's (ours is 17, which keeps NuHepMC output on).

ARG BASE_IMAGE=lbathepeters/root_v6_30_04:alma9
ARG NEUT_VERSION=6.1.4
ARG NCORES=4

FROM ${BASE_IMAGE} AS neut_build
ARG NEUT_VERSION
ARG NCORES
WORKDIR /

RUN mkdir -p ~/.ssh && ssh-keyscan github.com > ~/.ssh/known_hosts

WORKDIR /opt
RUN --mount=type=ssh \
    git clone --depth 1 --branch ${NEUT_VERSION} git@github.com:neut-devel/neut.git neut-src

# Record what was actually built -- the tag is the source of truth here, since
# NEUT's CMakeLists project(VERSION ...) lags the tag it is released under.
RUN cd /opt/neut-src && git describe --tags --always > /opt/neut-src/.built-from

# The ssh mount is needed here as well, not just for the clone above: with
# NEUT_DOWNLOAD_DATA=ON (the default) the configure step FetchContent-clones the
# RMF tables from a SECOND private repo, neut-devel/neut-data, at tag 1.1.0.
WORKDIR /opt/neut-build
RUN --mount=type=ssh cmake /opt/neut-src \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/opt/neut/${NEUT_VERSION}
RUN --mount=type=ssh make install -j ${NCORES}
RUN cp /opt/neut-src/.built-from /opt/neut/${NEUT_VERSION}/


FROM ${BASE_IMAGE}
ARG NEUT_VERSION
WORKDIR /

COPY --from=neut_build /opt/neut/${NEUT_VERSION} /opt/neut/${NEUT_VERSION}

ENV NEUT_VERSION=${NEUT_VERSION}
ENV NEUT_ROOT=/opt/neut/${NEUT_VERSION}
# lib64 as well as lib: NEUT installs its own libraries into lib/, but the
# bundled HepMC3 / spdlog / fmt land in lib64/ (CMake's GNUInstallDirs default on
# a 64-bit RHEL-family system). Without lib64 here, neutroot2 starts with 4
# unresolved libraries -- libHepMC3.so.4, libHepMC3rootIO.so.3, libfmt.so.10,
# libspdlog.so.1.14 -- even though they are present in the image.
ENV PATH=${NEUT_ROOT}/bin:${PATH} \
    LD_LIBRARY_PATH=${NEUT_ROOT}/lib:${NEUT_ROOT}/lib64:${LD_LIBRARY_PATH} \
    NEUT_CRSPATH=${NEUT_ROOT}/share/neut/crsdat \
    NEUT_CARDS=${NEUT_ROOT}/share/neut/Cards \
    ROOT_INCLUDE_PATH=${NEUT_ROOT}/include:${ROOT_INCLUDE_PATH} \
    PKG_CONFIG_PATH=${NEUT_ROOT}:${PKG_CONFIG_PATH} \
    OMP_NUM_THREADS=1
