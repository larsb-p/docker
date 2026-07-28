# syntax=docker/dockerfile:1
#
# GENIE R-3_06_02 (latest release, 2025-07-02). Adapted from alma9/genie/, which
# builds 3_04_02 -- the structure is deliberately kept identical so the two are
# easy to diff. Differences from that file are marked "3_06_02:".
#
# 3_06_02: spline/tune data comes from scisoft v3_06_00, NOT v3_06_02. There is
# no generic v3_06_02 spline set published -- only genie_xsec/v3_06_02_sbn1 and
# _sbn2, which are SBN-specific -- and genie_phyopt stops at v3_06_00 entirely
# (v3_06_02 is a 404). Using 3_06_00 splines with a 3_06_02 build is the same
# arrangement the 3_04_02 image already uses (it fetches 3_04_00 tunes).
#
# 3_06_02: the tune list changed. G21_11a_00_000 does NOT exist for 3_06_00
# (404), so it is dropped, and N24_20i_02_11b -- which is new in 3_06_00 -- is
# fetched instead. Available tunes for 3_06_00 are:
#   AR23_20i_00_000  G18_02a_00_000  G18_10a_02_11a  G18_10a_02_11b  N24_20i_02_11b

# NCORES is passed by make_genie.sh but the 3_04_02 Dockerfile never declared
# it, so the build silently ran at -j 4 regardless. It matters most for the
# emulated amd64 half, which is the slowest thing in this repo.
ARG NCORES=4

FROM lbathepeters/buildbox:alma9 AS lhapdf_build
ARG NCORES

WORKDIR /

RUN mkdir -p /opt/LHAPDF-src
WORKDIR /opt/LHAPDF-src

ENV LHAPDF_VERS=6.5.1

RUN wget https://lhapdf.hepforge.org/downloads/LHAPDF-${LHAPDF_VERS}.tar.gz \
         -O LHAPDF-${LHAPDF_VERS}.tar.gz \
    && tar -zxvf LHAPDF-${LHAPDF_VERS}.tar.gz

WORKDIR /opt/LHAPDF-src/LHAPDF-6.5.1/config/
RUN  wget -O config.guess 'https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD' \
 && wget -O config.sub 'https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD'

RUN mkdir -p /opt/LHAPDF-build /opt/LHAPDF/${LHAPDF_VERS}
WORKDIR /opt/LHAPDF-build

RUN ln -s /usr/bin/python3 /usr/bin/python
RUN /opt/LHAPDF-src/LHAPDF-${LHAPDF_VERS}/configure \
                                    --prefix=/opt/LHAPDF/${LHAPDF_VERS} \
    && make install -j ${NCORES}

FROM lbathepeters/root_v6_30_04:alma9 AS genie_build
# Must be repeated: ARG scope is per-stage, and without it ${NCORES} below would
# expand to empty, turning "make -j ${NCORES}" into an unlimited-parallelism
# "make -j" that can exhaust memory.
ARG NCORES
WORKDIR /

COPY --from=lhapdf_build /opt/LHAPDF/ /opt/LHAPDF/
ENV LHAPDF_VERS=6.5.1
ENV LHAPATH=/opt/LHAPDF/${LHAPDF_VERS}
ENV PATH=${LHAPATH}/bin:${PATH}
ENV LD_LIBRARY_PATH=${LHAPATH}/lib:${LD_LIBRARY_PATH}
ENV LHAPDF_INC=${LHAPATH}/include
ENV LHAPDF_LIB=${LHAPATH}/lib
ENV ROOT_INCLUDE_PATH=/opt/root/v6-30-04/include

# 3_06_02: bumped from 3_04_02.
ENV GENIE_VERSION=3_06_02

WORKDIR /opt/
# 3_06_02: BOTH Generator and Reweight come from the larsb-p forks, and they
# must be kept as a matched pair.
#
# Building stock GENIE-MC/Generator R-3_06_02 against the Reweight branch below
# FAILS: GReWeightXSecMEC.cxx includes
#   Physics/Multinucleon/XSection/MartiniEricsonChanfrayMarteauMECPXSec2024.h
# which does not exist in stock GENIE (404 on both R-3_06_02 and master). That
# header is the Martini-Ericson-Chanfray-Marteau MEC model, added on the fork
# branch below (PR #478).
#
# CAVEAT ON THE NAME: this directory is called genie_3_06_02 for continuity with
# alma9/genie/, but the fork branch reports VERSION 999.999.999 -- GENIE's
# development placeholder -- so the built libraries are named
# libGPhQELXS-999.999.999.so rather than -3.06.02.so, and this is NOT a released
# GENIE 3.06.02. It is 3.06.02-era master plus the Martini MEC work.
RUN git clone --depth 1 --branch larsb-p_Martini_GENIEReweight_version \
      https://github.com/larsb-p/Generator.git Generator-src
RUN git clone --depth 1 --branch larsbp_update_to_GENIEv3_06_02 \
      https://github.com/larsb-p/Reweight.git Reweight-src

ENV GENIE=/opt/Generator-src

WORKDIR /opt/Generator-src
RUN mkdir -p /opt/genie/${GENIE_VERSION} \
 && ./configure --prefix=/opt/genie/${GENIE_VERSION} --enable-debug --enable-lhapdf6 \
 && make -j ${NCORES} && make install

ENV GENIE_REWEIGHT=/opt/Reweight-src
WORKDIR /opt/Reweight-src
RUN echo "ROOT_INCLUDE_PATH: $ROOT_INCLUDE_PATH"
RUN make && make install

RUN cp /opt/Generator-src/data/evgen/pdfs/GRV98lo_patched.LHgrid \
    ${LHAPATH}/GRV98lo_patched.LHgrid

ENV GENIE="/opt/genie/${GENIE_VERSION}"
ENV GENIE_REWEIGHT=${GENIE}

# Install some things that the GENIE install script forget.
RUN cp /opt/Generator-src/VERSION ${GENIE}/
RUN cp -r /opt/Generator-src/config ${GENIE}/
RUN mkdir -p ${GENIE}/data/
RUN cp -r /opt/Generator-src/data/evgen ${GENIE}/data/

RUN mv ${GENIE}/config/Messenger_whisper.xml ${GENIE}/config/Messenger.xml
RUN sed -i '$ d' ${GENIE}/config/Messenger.xml
RUN echo '  <priority msgstream="ResonanceDecay">      FATAL </priority>' >> ${GENIE}/config/Messenger.xml
RUN echo '  <priority msgstream="Pythia6Decay">        FATAL </priority>' >> ${GENIE}/config/Messenger.xml
RUN echo '  <priority msgstream="INukeNucleonCorr">    FATAL </priority>' >> ${GENIE}/config/Messenger.xml
RUN echo '  <priority msgstream="gevgen_fnal">         FATAL </priority>' >> ${GENIE}/config/Messenger.xml
RUN echo '</messenger_config>' >> ${GENIE}/config/Messenger.xml

RUN mkdir -p ${GENIE}/src/make/
RUN cp /opt/Generator-src/src/make/Make.config_no_paths \
                      ${GENIE}/src/make/

WORKDIR ${GENIE}/src
RUN ln -s -t . ../include/GENIE/*/

## Final container
FROM lbathepeters/root_v6_30_04:alma9

COPY --from=lhapdf_build /opt/LHAPDF /opt/LHAPDF
ENV LHAPDF_VERS=6.5.1 \
    LHAPATH=/opt/LHAPDF/6.5.1 \
    PATH=/opt/LHAPDF/6.5.1/bin:${PATH} \
    LD_LIBRARY_PATH=/opt/LHAPDF/6.5.1/lib:${LD_LIBRARY_PATH} \
    LHAPDF_INC=/opt/LHAPDF/6.5.1/include \
    LHAPDF_LIB=/opt/LHAPDF/6.5.1/lib \
    GENIE_VERSION=3_06_02 \
    GENIE=/opt/genie/3_06_02 \
    GENIE_REWEIGHT=/opt/genie/3_06_02

COPY --from=genie_build /opt/genie /opt/genie

RUN mkdir -p /opt/genie/utils/
ADD  genie_fetch_tune \
     genie_set_tune \
     genie_list_tunes \
     gxspl.min.awk \
  /opt/genie/utils/

# 3_06_02: fetch from 3_06_00 (see header). G21_11a_00_000 dropped -- it is not
# published for 3_06_00 -- and N24_20i_02_11b added.
RUN /opt/genie/utils/genie_fetch_tune 3_06_00 AR23_20i_00_000 \
    && /opt/genie/utils/genie_fetch_tune 3_06_00 G18_10a_02_11a \
    && /opt/genie/utils/genie_fetch_tune 3_06_00 N24_20i_02_11b

ENV PATH=${GENIE}/bin:/opt/genie/utils/:${PATH} \
    LD_LIBRARY_PATH=${GENIE_REWEIGHT}/lib:${GENIE}/lib:${LD_LIBRARY_PATH} \
    ROOT_INCLUDE_PATH=${GENIE}/include/GENIE:${ROOT_INCLUDE_PATH}\
    GENIE_XSEC_VERSION=3_06_00 \
    GENIE_XSEC_TUNE=AR23_20i_00_000 \
    GENIE_XSEC_DIR=/opt/genie_xsec/3_06_00/AR23_20i_00_000 \
    GENIE_XSEC_FILE=/opt/genie_xsec/3_06_00/AR23_20i_00_000/gxspl-min.xml.gz \
    GENIE_PHYOPT_DIR=/opt/genie_phyopt/3_06_00/dkcharmtau \
    GXMLPATH=/opt/genie_phyopt/3_06_00/dkcharmtau:/opt/genie_xsec/3_06_00/AR23_20i_00_000
