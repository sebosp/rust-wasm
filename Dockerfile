FROM rust:1.27.2
MAINTAINER Seb Ospina <kraige@gmail.com>
ENV USER root
ENV PATH /root/.cargo/bin:$PATH
RUN rustup override set nightly \
  && rustup default nightly \
  && rustup target add wasm32-unknown-unknown --toolchain nightly \
  && cargo +nightly install wasm-bindgen-cli \
  && git clone --depth 1 https://github.com/juj/emsdk.git \
  && emsdk/emsdk install latest \
  && emsdk/emsdk activate latest \
  && apt-get update \
  && apt-get install -y apt-transport-https lsb-release \
  && curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - \
  && echo 'deb https://deb.nodesource.com/node_10.x stretch main' > /etc/apt/sources.list.d/nodesource.list \
  && echo 'deb-src https://deb.nodesource.com/node_10.x stretch main' >> /etc/apt/sources.list.d/nodesource.list \
  && apt-get update \
  && apt-get install -y nodejs \
  && cd / \
  && cargo new maindeps \
  && cd maindeps \
  && cargo new wasm-data --lib
COPY Cargo.toml /maindeps/Cargo.toml
COPY Rocket.toml /maindeps/Rocket.toml
COPY wasm-data/Cargo.toml /maindeps/wasm-data/Cargo.toml
RUN cd /maindeps \
  && cargo install wasm-gc --root /maindeps/tmp \
  && cargo +nightly build --target wasm32-unknown-unknown --release -p wasm-data \
  && mkdir /code \
  && mv /maindeps/Cargo.toml /code/Cargo.toml \
  && mv /maindeps/Rocket.toml /code/Rocket.toml \
  && rm -rf /maindeps
WORKDIR /code
COPY wasm-data /code/wasm-data
COPY src /code/src
RUN cd wasm-data \
  && cargo test \
  && cd .. \
  && cargo install wasm-gc --root /code/tmp \
  && cargo +nightly build --target wasm32-unknown-unknown --release -p wasm-data \
  && mkdir /code/static \
  && /code/tmp/bin/wasm-gc target/wasm32-unknown-unknown/release/wasm_data.wasm -o /code/static/wasm_data.gc.wasm
RUN cargo test \
  && cargo install --path . \
  && mv target/release/rust-wasm / \
  && rm -rf target
COPY static/index.html /code/static/
CMD ["/rust-wasm"]
