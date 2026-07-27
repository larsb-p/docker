# syntax=docker/dockerfile:1
#
# Achilles v0.3.1 -- the latest CODE tag. Note that GitHub's "latest release"
# for this repo is achilles-data-v1 (2026-07-10), which is a data release, not a
# version of the generator; don't be fooled into tagging an image after it.
#
# Public repo, so no ssh agent needed here (unlike NEUT).
#
# Upstream ships its own Dockerfile, but it is Alpine/musl based and just runs
# the binary out of the build tree. This is the same build, rebased onto the
# alma9 + ROOT stack used by the rest of these images.
#
# Base choice: HDF5 (needed by the HighFive dependency) is already present in
# the ROOT base as hdf5-devel 1.12.1, so no extra dnf layer is required. ROOT
# itself is optional for Achilles -- ACHILLES_ENABLE_ROOT defaults to OFF -- but
# it is turned ON below so that ROOT-format flux files can be read, which is the
# whole point of having it in the base.
#
# CAVEAT on reproducibility: several of Achilles' CPM dependencies are pinned to
# GIT_TAG master (yaml-cpp, yaml-fortran, and the Fortran interface), so two
# builds of the same Achilles tag are NOT guaranteed to be identical. That is
# upstream's choice; it cannot be fixed from here without patching external/.

ARG BASE_IMAGE=lbathepeters/root_v6_30_04:alma9
ARG ACHILLES_VERSION=v0.3.1
ARG NCORES=4

FROM ${BASE_IMAGE} AS achilles_build
ARG ACHILLES_VERSION
ARG NCORES
WORKDIR /opt

RUN git clone --depth 1 --branch ${ACHILLES_VERSION} \
      https://github.com/AchillesGen/Achilles.git achilles-src

# Build directly in the FINAL location, not a scratch dir. Achilles links its
# CPM dependencies (docopt, fmt, spdlog, yaml-cpp, HepMC3, NuHepMC) straight out
# of the build tree and bakes absolute RPATHs like
#   /opt/achilles-build/_deps/docopt-build:/opt/achilles-build/lib:...
# so building in one directory and COPYing to another leaves every one of those
# dangling and the binary dies with "libdocopt.so.0: cannot open shared object
# file". Keeping build dir == install dir keeps the RPATHs valid.
WORKDIR /opt/achilles/${ACHILLES_VERSION}
# CMAKE_POLICY_VERSION_MINIMUM mirrors upstream's own Dockerfile: some of the
# CPM-fetched dependencies still declare a pre-3.5 cmake_minimum_required.
RUN cmake /opt/achilles-src \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
      -DACHILLES_ENABLE_ROOT=ON
RUN cmake --build . -j ${NCORES}


FROM ${BASE_IMAGE}
ARG ACHILLES_VERSION
WORKDIR /

# Ship the build tree, as upstream does: Achilles' CMake copies the runtime data
# (data/, flux/, examples/, run.yml, cascade.yml, FormFactors.yml,
# parameters.dat) into the BUILD directory, not into an install prefix, so a
# bare `cmake --install` would leave the generator without its inputs. The
# source and destination paths must match -- see the RPATH note above.
COPY --from=achilles_build /opt/achilles/${ACHILLES_VERSION} /opt/achilles/${ACHILLES_VERSION}

ENV ACHILLES_VERSION=${ACHILLES_VERSION}
ENV ACHILLES_ROOT=/opt/achilles/${ACHILLES_VERSION}
ENV PATH=${ACHILLES_ROOT}/bin:${PATH} \
    LD_LIBRARY_PATH=${ACHILLES_ROOT}/lib:${LD_LIBRARY_PATH}

WORKDIR ${ACHILLES_ROOT}
