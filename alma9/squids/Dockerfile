# syntax=docker/dockerfile:1
FROM lbathepeters/root_v6_30_04:alma9 AS squids_build

WORKDIR /

WORKDIR /opt

ARG SQUIDS_VERSION=v1.3.0
ARG NCORES=4

RUN mkdir -p /opt/squids-src

RUN git clone --depth 1 https://github.com/jsalvado/SQuIDS.git --branch ${SQUIDS_VERSION} /opt/squids-src
WORKDIR /opt/squids-src
#RUN ./configure --with-gsl-incdir=/usr/include/gsl/ --with-gsl-libdir=/usr/lib64/
RUN ./configure --with-gsl=$(gsl-config --prefix)
RUN make -j ${NCORES}
RUN make install
RUN ./configure --prefix=$HOME

FROM lbathepeters/root_v6_30_04:alma9

COPY --from=squids_build /opt/squids-src /opt/squids-src
