FROM nvidia/cuda:9.0-base-ubuntu16.04 as build

RUN apt-get update && apt-get install -y --no-install-recommends \
        g++ \
        ca-certificates \
        wget \
        cuda-cudart-dev-9-0 \
        cuda-misc-headers-9-0 \
        cuda-nvml-dev-9-0 && \
    rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.9.1
RUN wget -nv -O - https://storage.googleapis.com/golang/go${GOLANG_VERSION}.linux-amd64.tar.gz \
    | tar -C /usr/local -xz
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

ENV CGO_CFLAGS "-I /usr/local/cuda-9.0/include -I /usr/include/nvidia/gdk"
ENV CGO_LDFLAGS "-L /usr/local/cuda-9.0/lib64"
ENV PATH=$PATH:/usr/local/nvidia/bin:/usr/local/cuda/bin
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/nvidia/lib:/usr/local/nvidia/lib64

WORKDIR /go/src/nvidia-device-plugin
COPY . .

RUN go install -v nvidia-device-plugin


FROM nvidia/cuda:9.0-base-ubuntu16.04

COPY --from=build /go/bin/nvidia-device-plugin /usr/bin/nvidia-device-plugin

CMD ["nvidia-device-plugin"]
