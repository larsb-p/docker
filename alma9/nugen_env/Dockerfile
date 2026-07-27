# syntax=docker/dockerfile:1
FROM lbathepeters/buildbox:alma9 AS lhapdf_build
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
    && make install -j 4

FROM lbathepeters/root_v6_30_04:alma9 AS genie_build
WORKDIR /

COPY --from=lhapdf_build /opt/LHAPDF/ /opt/LHAPDF/
ENV LHAPDF_VERS=6.5.1
ENV LHAPATH=/opt/LHAPDF/${LHAPDF_VERS}
ENV PATH=${LHAPATH}/bin:${PATH}
ENV LD_LIBRARY_PATH=${LHAPATH}/lib:${LD_LIBRARY_PATH}
ENV LHAPDF_INC=${LHAPATH}/include
ENV LHAPDF_LIB=${LHAPATH}/lib
ENV ROOT_INCLUDE_PATH=/opt/root/v6-30-04/include

## Final container
FROM lbathepeters/root_v6_30_04:alma9

COPY --from=lhapdf_build /opt/LHAPDF /opt/LHAPDF
ENV LHAPDF_VERS=6.5.1 \
    LHAPATH=/opt/LHAPDF/6.5.1 \
    PATH=/opt/LHAPDF/6.5.1/bin:${PATH} \
    LD_LIBRARY_PATH=/opt/LHAPDF/6.5.1/lib:${LD_LIBRARY_PATH} \
    LHAPDF_INC=/opt/LHAPDF/6.5.1/include \
    LHAPDF_LIB=/opt/LHAPDF/6.5.1/lib \
