FROM ubuntu:22.04 AS crun
WORKDIR /wasm

RUN DEBIAN_FRONTEND=noninteractive apt update \
    && DEBIAN_FRONTEND=noninteractive apt install -y curl make git gcc build-essential pkgconf libtool libsystemd-dev libprotobuf-c-dev libcap-dev libseccomp-dev libyajl-dev libgcrypt20-dev go-md2man autoconf python3 automake \
    && curl https://raw.githubusercontent.com/WasmEdge/WasmEdge/master/utils/install.sh | bash -s -- -p /usr/local --version=0.11.2 \
    && git clone --depth 1 --branch 1.8.4 https://github.com/containers/crun.git \
    && cd crun \
    && ./autogen.sh \
    && ./configure --with-wasmedge --enable-embedded-yajl\
    && make 

FROM kindest/node:v1.25.8

# add the crun runtime handler to the containerd config
COPY containerd/* /tmp/
COPY --from=crun /wasm/crun/crun /usr/local/bin/crun
COPY --from=crun /usr/local/lib/libwasmedge.so /usr/local/lib/libwasmedge.so.0

# if cgroups are enabled on crun, dbus is required?!
# with out it FailedCreatePodSandBox has issue as - OCI runtime create failed: cannot open sd-bus
RUN DEBIAN_FRONTEND=noninteractive apt update \
    && DEBIAN_FRONTEND=noninteractive apt install -y dbus \
    && cat /tmp/config.toml >> /etc/containerd/config.toml \
    && jq -s '.[0] * .[1]' /etc/containerd/cri-base.json /tmp/annotations.json > /etc/containerd/cri-wasm.json \
    && ln -s /usr/local/lib/libwasmedge.so.0 /usr/local/lib/libwasmedge.so \
    && ldconfig
