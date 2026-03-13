FROM rust:1.92.0-slim-bookworm

ARG ELECTRS_REPO=https://github.com/Blockstream/electrs.git
ARG ELECTRS_REF=new-index

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    clang \
    cmake \
    g++ \
    gcc \
    git \
    libclang-dev \
    libssl-dev \
    libzmq3-dev \
    make \
    pkg-config \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /src

RUN git clone --depth 1 --branch "${ELECTRS_REF}" "${ELECTRS_REPO}" electrs

WORKDIR /src/electrs

RUN cargo build --locked --release --features liquid --bin electrs \
 && install -Dm755 target/release/electrs /usr/local/bin/electrs \
 && rm -rf /src/electrs

WORKDIR /

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh \
 && mkdir -p /data /tmp/elements

VOLUME ["/data"]

EXPOSE 50001 4224

ENTRYPOINT ["/entrypoint.sh"]

