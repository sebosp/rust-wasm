FROM rust:1.27.2
MAINTAINER Seb Ospina <kraige@gmail.com>
RUN rustup override set nightly \
  && rustup default nightly \
  && rustup target add wasm32-unknown-unknown --toolchain nightly \
  && git clone --depth 1 https://github.com/juj/emsdk.git \
  && emsdk/emsdk install latest \
  && emsdk/emsdk activate latest \
  && mkdir /code
COPY Cargo.toml /code/Cargo.toml
COPY Rocket.toml /code/Rocket.toml
COPY wasm-data /code/wasm-data
COPY src /code/src
WORKDIR /code
RUN cargo install wasm-gc --root /code/tmp \
  && cargo +nightly build --target wasm32-unknown-unknown --release -p wasm-data \
  && mkdir /code/static \
  && /code/tmp/bin/wasm-gc target/wasm32-unknown-unknown/release/wasm_data.wasm -o /code/static/wasm_data.gc.wasm
RUN cargo test \
  && cargo install --path .
COPY static/index.html /code/
