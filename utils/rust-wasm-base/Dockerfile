FROM rust:1.27.1
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
