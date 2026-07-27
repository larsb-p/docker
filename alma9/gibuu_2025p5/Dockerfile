# syntax=docker/dockerfile:1
#
# GiBUU "Release 2025, patch 5 (April 24, 2026)".
#
# NOTE: hepforge only serves the current patch level under the fixed name
# release2025.tar.gz -- there is no per-patch URL. The build therefore prints
# release/version.txt and asserts it matches GIBUU_VERSION, so a silent
# upstream patch bump fails the build instead of mislabelling the image.
#
# Built on the ROOT base rather than plain buildbox: withROOT=1 needs
# root-config to build/link the RootTuple library.

ARG BASE_IMAGE=lbathepeters/root_v6_30_04:alma9
ARG GIBUU_VERSION=2025p5
ARG NCORES=2

FROM ${BASE_IMAGE} AS gibuu_build
ARG GIBUU_VERSION
ARG NCORES
WORKDIR /opt/GiBUU-src

RUN wget -nv --content-disposition https://gibuu.hepforge.org/downloads?f=release2025.tar.gz \
 && wget -nv --content-disposition https://gibuu.hepforge.org/downloads?f=buuinput2025.tar.gz \
 && wget -nv --content-disposition https://gibuu.hepforge.org/downloads?f=buuinput2025_inMed.tar.gz \
 && wget -nv --content-disposition https://gibuu.hepforge.org/downloads?f=libraries2025_RootTuple.tar.gz \
 && wget -nv --content-disposition https://gibuu.hepforge.org/downloads?f=libraries2025_HEPMC3.tar.gz

RUN tar -xzf release2025.tar.gz \
 && tar -xzf buuinput2025.tar.gz \
 && tar -xzf buuinput2025_inMed.tar.gz \
 && tar -xzf libraries2025_RootTuple.tar.gz \
 && tar -xzf libraries2025_HEPMC3.tar.gz \
 && rm -f ./*.tar.gz

# Fail loudly if hepforge has moved the current release on from what we claim.
RUN cat release/version.txt \
 && grep -qE "Release 2025, patch 5" release/version.txt

WORKDIR /opt/GiBUU-src/release
RUN make buildRootTuple
RUN make -j ${NCORES} withROOT=1


FROM ${BASE_IMAGE}
ARG GIBUU_VERSION
WORKDIR /

RUN mkdir -p /opt/GiBUU/${GIBUU_VERSION}/bin
COPY --from=gibuu_build /opt/GiBUU-src/release/objects/GiBUU.x  /opt/GiBUU/${GIBUU_VERSION}/bin/
COPY --from=gibuu_build /opt/GiBUU-src/release/testRun/jobCards /opt/GiBUU/${GIBUU_VERSION}/jobCards
COPY --from=gibuu_build /opt/GiBUU-src/buuinput                 /opt/GiBUU/${GIBUU_VERSION}/buuinput

ENV GIBUU_VERSION=${GIBUU_VERSION}
ENV GiBUU=/opt/GiBUU/${GIBUU_VERSION} \
    GiBUU_JOBCARDS=/opt/GiBUU/${GIBUU_VERSION}/jobCards \
    GiBUU_BUUINPUTS=/opt/GiBUU/${GIBUU_VERSION}/buuinput \
    PATH=/opt/GiBUU/${GIBUU_VERSION}/bin:${PATH}
