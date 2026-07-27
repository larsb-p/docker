FROM lbathepeters/nuoscillator_1.0.2:alma9 AS mach3_build

# Configure SSH and known_hosts
RUN mkdir -p -m 0700 ~/.ssh && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts && \
    ssh-keyscan git.t2k.org >> ~/.ssh/known_hosts


# Debug SSH connection (optional)
#RUN --mount=type=ssh ssh -T git@github.com || true

WORKDIR /opt/

# Clone the repository
RUN --mount=type=ssh git clone --recurse-submodules git@github.com:t2k-software/MaCh3 --branch dbarrow257/feature/NuSQUIDS /opt/MaCh3

#RUN --mount=type=ssh git clone --recurse-submodules git@github.com:t2k-software/MaCh3 /opt/MaCh3

#RUN --mount=type=ssh git clone git@git.t2k.org:t2k-sk/t2ksk-common.git

WORKDIR /opt/MaCh3

#RUN git checkout dbarrow257/fix/develop_fixes
#RUN git checkout dbarrow257/feature/NuSQUIDS

RUN ./setup_psyche.sh
RUN ./setup_inputs.sh --SK

RUN --mount=type=ssh git clone git@git.t2k.org:t2k-sk/t2ksk-common.git

#RUN --mount=type=ssh git submodule update --init --recursive


RUN rm -rf build
RUN mkdir build
WORKDIR build
RUN --mount=type=ssh cmake .. -DNuSQUIDSLinear_ENABLED=ON -DCUDAProb3Linear_ENABLED=ON -DNuFASTLinear_ENABLED=ON

RUN make install

FROM lbathepeters/nuoscillator_1.0.2:alma9

WORKDIR /

COPY --from=mach3_build /opt/MaCh3 /opt/MaCh3

WORKDIR /opt/MaCh3

#RUN --mount=type=ssh git submodule update --init --recursive --remote
