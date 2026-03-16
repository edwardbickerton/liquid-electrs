FROM rust:1.92.0-slim-bookworm

ARG ELECTRS_REF=4e1fe8e6b4f771e270709450750ac9f20f8d05a1

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    clang \
    cmake \
    curl \
    g++ \
    gcc \
    git \
    ca-certificates \
    libclang-dev \
    libssl-dev \
    libzmq3-dev \
    make \
    patch \
    pkg-config \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /src

RUN curl -fsSL "https://github.com/Blockstream/electrs/archive/${ELECTRS_REF}.tar.gz" \
    | tar -xz -C /src \
 && mv "/src/electrs-${ELECTRS_REF}" /src/electrs

WORKDIR /src/electrs

COPY patches /patches

RUN patch -p1 < /patches/0001-checkpoint-initial-sync.patch \
 && cargo build --locked --release --features liquid --bin electrs \
 && install -Dm755 target/release/electrs /usr/local/bin/electrs \
 && rm -rf /src/electrs

WORKDIR /

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh \
 && mkdir -p /data /tmp/elements

VOLUME ["/data"]

EXPOSE 50001 4224

ENTRYPOINT ["/entrypoint.sh"]
