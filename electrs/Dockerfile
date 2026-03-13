FROM rust:1.92.0-slim-bookworm

ARG ELECTRS_REF=b84e2a0738d4f3256dc375f23dd5ef10b4aef0d5

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
    pkg-config \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /src

RUN curl -fsSL "https://github.com/Blockstream/electrs/archive/${ELECTRS_REF}.tar.gz" \
    | tar -xz -C /src \
 && mv "/src/electrs-${ELECTRS_REF}" /src/electrs

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
