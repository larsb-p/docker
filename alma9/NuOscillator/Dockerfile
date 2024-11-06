FROM lbathepeters/root_v6_30_04:alma9 AS nuoscillator_build

WORKDIR /opt/

RUN git clone https://github.com/dbarrow257/NuOscillator --branch feature_NuSQUIDS /opt/NuOscillator
WORKDIR /opt/NuOscillator
RUN mkdir build
WORKDIR build
RUN cmake .. -DUseNuSQUIDSLinear=1

RUN make install

FROM lbathepeters/root_v6_30_04:alma9

WORKDIR /

COPY --from=nuoscillator_build /opt/NuOscillator /opt/NuOscillator

WORKDIR /opt/NuOscillator

RUN echo 'source /opt/NuOscillator/build/Linux/bin/setup.NuOscillator.sh' >> ~/.bashrc
