FROM rust:1.27.1 as wasm_data_builder
MAINTAINER Seb Ospina <kraige@gmail.com>
RUN set -xe \
  && rustup override set nightly \
  && rustup default nightly \
  && rustup target add wasm32-unknown-unknown --toolchain nightly \
  && cargo install wasm-gc \
  && git clone --depth 1 https://github.com/juj/emsdk.git \
  && cd emsdk \
  && ./emsdk install latest \
  && ./emsdk activate latest \
  && echo "source $HOME/emsdk_portable/emsdk_env.sh" > /root/.bashrc
COPY wasm-data/Cargo.lock /code/Cargo.lock
COPY wasm-data/Cargo.toml /code/Cargo.toml
COPY wasm-data/src/lib.rs /code/src/lib.rs
WORKDIR /code
RUN cargo +nightly build --target wasm32-unknown-unknown --release
RUN wasm-gc target/wasm32-unknown-unknown/release/wasm_data.wasm -o target/wasm32-unknown-unknown/release/wasm_data.gc.wasm

FROM centos:7
EXPOSE 8080
CMD ["/rust-wasm"]
COPY ./ /
COPY --from=wasm_data_builder /code/target/wasm32-unknown-unknown/release/wasm_data.gc.wasm ./static/
