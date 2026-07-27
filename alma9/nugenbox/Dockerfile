# syntax=docker/dockerfile:1
#
# nugenbox -- every generator in one image, all on PATH, all "just working".
#
# This image COMPILES NOTHING. Each generator is COPYed out of its own already
# published image, so building this is a matter of pulling layers and setting
# environment. All the source images derive from lbathepeters/root_v6_30_04:alma9
# and so does this one, which means the (large) ROOT + Alma9 layers are shared
# rather than duplicated five times.
#
# PREREQUISITE: every image referenced below must already be pushed. Build order
# is nuwro / gibuu / neut / achilles / genie first, then this.
#
# WHY THE ENV BLOCK IS WRITTEN OUT LONGHAND:
# COPY --from copies FILES ONLY -- it does not inherit ENV from the source
# image. Every PATH, LD_LIBRARY_PATH and ROOT_INCLUDE_PATH entry that each
# generator's own Dockerfile sets has to be restated here, merged by hand.
# Setting them in separate ENV lines that each append to ${PATH} would work too,
# but doing it in one place makes the collisions visible -- and there are
# collisions: NuWro, NEUT and GENIE all want a slice of ROOT_INCLUDE_PATH, and
# Achilles, NEUT and GENIE all want LD_LIBRARY_PATH.

ARG BASE_IMAGE=lbathepeters/root_v6_30_04:alma9

ARG NUWRO_IMAGE=lbathepeters/nuwro_21_09:alma9
ARG GIBUU_IMAGE=lbathepeters/gibuu_2025p5:alma9
ARG NEUT_IMAGE=lbathepeters/neut_6_1_4:alma9
ARG ACHILLES_IMAGE=lbathepeters/achilles_0_3_1:alma9
ARG GENIE_IMAGE=lbathepeters/genie_3_06_02:alma9

FROM ${NUWRO_IMAGE}    AS nuwro_src
FROM ${GIBUU_IMAGE}    AS gibuu_src
FROM ${NEUT_IMAGE}     AS neut_src
FROM ${ACHILLES_IMAGE} AS achilles_src
FROM ${GENIE_IMAGE}    AS genie_src

FROM ${BASE_IMAGE}
WORKDIR /

# ---------------------------------------------------------------- NuWro 21.09.2
COPY --from=nuwro_src    /opt/nuwro         /opt/nuwro

# ---------------------------------------------------------------- GiBUU 2025p5
COPY --from=gibuu_src    /opt/GiBUU         /opt/GiBUU

# ---------------------------------------------------------------- NEUT 6.1.4
COPY --from=neut_src     /opt/neut          /opt/neut

# ---------------------------------------------------------------- Achilles 0.3.1
# NOTE: Achilles bakes absolute RPATHs into its binary pointing at
# /opt/achilles/v0.3.1/_deps/... , so this path must not be changed.
COPY --from=achilles_src /opt/achilles      /opt/achilles

# ---------------------------------------------------------------- GENIE 3.06.02
# GENIE needs its LHAPDF build and its spline/tune data as well as the code.
COPY --from=genie_src    /opt/genie         /opt/genie
COPY --from=genie_src    /opt/LHAPDF        /opt/LHAPDF
COPY --from=genie_src    /opt/genie_xsec    /opt/genie_xsec
COPY --from=genie_src    /opt/genie_phyopt  /opt/genie_phyopt

# ---------------------------------------------------------------- merged env
ENV NUWRO=/opt/nuwro/21.09.2 \
    GiBUU=/opt/GiBUU/2025p5 \
    GiBUU_JOBCARDS=/opt/GiBUU/2025p5/jobCards \
    GiBUU_BUUINPUTS=/opt/GiBUU/2025p5/buuinput \
    NEUT_VERSION=6.1.4 \
    NEUT_ROOT=/opt/neut/6.1.4 \
    NEUT_CRSPATH=/opt/neut/6.1.4/share/neut/crsdat \
    NEUT_CARDS=/opt/neut/6.1.4/share/neut/Cards \
    ACHILLES_VERSION=v0.3.1 \
    ACHILLES_ROOT=/opt/achilles/v0.3.1 \
    LHAPDF_VERS=6.5.1 \
    LHAPATH=/opt/LHAPDF/6.5.1 \
    LHAPDF_INC=/opt/LHAPDF/6.5.1/include \
    LHAPDF_LIB=/opt/LHAPDF/6.5.1/lib \
    GENIE_VERSION=3_06_02 \
    GENIE=/opt/genie/3_06_02 \
    GENIE_REWEIGHT=/opt/genie/3_06_02 \
    GENIE_XSEC_VERSION=3_06_00 \
    GENIE_XSEC_TUNE=AR23_20i_00_000 \
    GENIE_XSEC_DIR=/opt/genie_xsec/3_06_00/AR23_20i_00_000 \
    GENIE_XSEC_FILE=/opt/genie_xsec/3_06_00/AR23_20i_00_000/gxspl-min.xml.gz \
    GENIE_PHYOPT_DIR=/opt/genie_phyopt/3_06_00/dkcharmtau \
    GXMLPATH=/opt/genie_phyopt/3_06_00/dkcharmtau:/opt/genie_xsec/3_06_00/AR23_20i_00_000

# NuWro's event1.so lives in its bin/ rather than a lib/, which is why that
# directory appears in LD_LIBRARY_PATH as well as in PATH -- it lets ROOT macros
# do gSystem->Load("event1.so") without an absolute path.
ENV PATH=/opt/nuwro/21.09.2/bin:/opt/GiBUU/2025p5/bin:/opt/neut/6.1.4/bin:/opt/achilles/v0.3.1/bin:/opt/genie/3_06_02/bin:/opt/genie/utils:/opt/LHAPDF/6.5.1/bin:/opt/utils:${PATH} \
    LD_LIBRARY_PATH=/opt/neut/6.1.4/lib:/opt/neut/6.1.4/lib64:/opt/achilles/v0.3.1/lib:/opt/genie/3_06_02/lib:/opt/LHAPDF/6.5.1/lib:/opt/nuwro/21.09.2/bin:${LD_LIBRARY_PATH} \
    ROOT_INCLUDE_PATH=/opt/nuwro/21.09.2/src:/opt/neut/6.1.4/include:/opt/genie/3_06_02/include/GENIE:${ROOT_INCLUDE_PATH} \
    PKG_CONFIG_PATH=/opt/neut/6.1.4:${PKG_CONFIG_PATH} \
    OMP_NUM_THREADS=1

COPY utils/nugen-info /opt/utils/
RUN chmod +x /opt/utils/*

WORKDIR /work
