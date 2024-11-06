# Use an ARM (aarch64) base image
FROM lbathepeters/buildbox:alma9 AS hdf5_build

RUN mkdir -p /opt/hdf5-src/
WORKDIR /opt/hdf5-src/

# Install dependencies for building HDF5
RUN dnf -y install \
    gcc gcc-c++ make wget zlib-devel

# Download and build HDF5
RUN wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.14/hdf5-1.14.0/src/hdf5-1.14.0.tar.gz \
    && tar -zxvf hdf5-1.14.0.tar.gz 

RUN mkdir -p /opt/hdf5-build \
    && cd /opt/hdf5-build \
    && /opt/hdf5-src/hdf5-1.14.0/configure --prefix=/opt/hdf5-src/hdf5-1.14.0 --enable-cxx \
    && make -j$(nproc) \
    && make install

FROM lbathepeters/squids_v1.3.0:alma9 AS nusquids_build

ENV LD_LIBRARY_PATH=/opt/squids-src/lib:$LD_LIBRARY_PATH

COPY --from=hdf5_build /opt/hdf5-src/ /opt/hdf5-src/

# Set environment variables for HDF5
ENV HDF5_VERS=1.14.0 
ENV HDF5PATH=/opt/hdf5-src/hdf5-${HDF5_VERS} 
ENV PATH=${HDF5PATH}/bin:$PATH \
    LD_LIBRARY_PATH=${HDF5PATH}/lib:${LD_LIBRARY_PATH} \
    HDF5_INC=${HDF5PATH}/include \
    HDF5_LIB=${HDF5PATH}/lib 

WORKDIR /opt

ARG NUSQUIDS_VERSION=1.11
ARG NCORES=4

ENV NUSQUIDS=nuSQuIDS
#RUN mkdir -p /opt/nusquids-src
RUN mkdir -p /opt/${NUSQUIDS}

#RUN git clone --depth 1  https://github.com/larsb-p/nuSQuIDS.git --branch ${NUSQUIDS_VERSION} /opt/nusquids-src
RUN git clone --depth 1  https://github.com/larsb-p/nuSQuIDS.git /opt/${NUSQUIDS}
WORKDIR /opt/${NUSQUIDS}
RUN ./configure --with-gsl=$(gsl-config --prefix) \
                --with-hdf5=${HDF5PATH} \
                --with-squids=/opt/squids-src

RUN make -j ${NCORES}
RUN make install
#RUN ./configure --prefix=$HOME

RUN dnf -y install python3-matplotlib

FROM lbathepeters/squids_v1.3.0:alma9

COPY --from=nusquids_build /usr/share/matplotlib /usr/share/matplotlib
COPY --from=hdf5_build /opt/hdf5-src/ /opt/hdf5-src/

# Set environment variables for HDF5
ENV HDF5_VERS=1.14.0
ENV HDF5PATH=/opt/hdf5-src/hdf5-${HDF5_VERS}
ENV PATH=${HDF5PATH}/bin:$PATH \
    LD_LIBRARY_PATH=${HDF5PATH}/lib:${LD_LIBRARY_PATH} \
    HDF5_INC=${HDF5PATH}/include \
    HDF5_LIB=${HDF5PATH}/lib

COPY --from=nusquids_build /opt/${NUSQUIDS} /opt/${NUSQUIDS}

ENV NUSQUIDSPATH=/opt/${NUSQUIDS}
ENV LD_LIBRARY_PATH=$(NUSQUIDSPATH)/lib:${LD_LIBRARY_PATH}

WORKDIR /opt/nuSQuIDS/examples/Decoherence

RUN g++ nuSQUIDSDecoh.cpp -I/opt/nuSQuIDS/include/ -I/opt/squids-src/include/ -c -o nuSQUIDSDecoh
RUN g++ main.cpp -L/usr/lib64/ -lgsl -lgslcblas -lm -L/opt/nuSQuIDS/lib -lnuSQuIDS -L/opt/squids-src/lib -lSQuIDS -I/opt/nuSQuIDS/include/ -I/opt/squids-src/include/ nuSQUIDSDecoh  -o main

ENV LD_LIBRARY_PATH=$(NUSQUIDSPATH)/lib:${LD_LIBRARY_PATH}:/opt/nuSQuIDS/lib:/opt/squids-src/lib
