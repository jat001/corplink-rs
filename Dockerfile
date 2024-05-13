FROM golang:latest as builder-go

WORKDIR /app
COPY libwg/build.sh .

RUN ./build.sh

FROM rust:latest as builder-rust

RUN apt-get update && \
    apt-get install -y clang && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder-go /app/libwg* libwg/
COPY src src
COPY build.rs Cargo.toml ./

RUN cargo build --release

FROM debian:latest

RUN apt-get update && \
    apt-get install -y wget && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

ARG GOST_VERSION=3.0.0-nightly.20240426
RUN mkdir -p /tmp/gost && \
    wget -O /tmp/gost.tar.gz https://github.com/go-gost/gost/releases/download/v${GOST_VERSION}/gost_${GOST_VERSION}_linux_amd64.tar.gz && \
    tar -xf /tmp/gost.tar.gz -C /tmp/gost && \
    mv /tmp/gost/gost . && \
    rm -rf /tmp/gost*

COPY --from=builder-rust /app/target/release/corplink-rs .
COPY docker-entrypoint.sh .

EXPOSE 1080
ENTRYPOINT [ "./docker-entrypoint.sh" ]
CMD [ "-L", ":1080" ]
