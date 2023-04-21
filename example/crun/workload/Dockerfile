FROM --platform=amd64 rust as build
WORKDIR /build
RUN rustup target add wasm32-wasi
COPY greet.rs .
RUN rustc greet.rs --target wasm32-wasi

FROM --platform=wasi/wasm32 scratch
COPY --from=build --chmod=755 /build/greet.wasm /greet.wasm
ENTRYPOINT [ "/greet.wasm" ]
