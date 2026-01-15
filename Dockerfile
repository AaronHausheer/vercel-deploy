# Build-Stage
FROM rust:1.85 AS builder
WORKDIR /app

# Dependencies cachen
COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release
RUN rm -rf src

# Eigentlichen Code
COPY . .
RUN cargo build --release --bin main

# Runtime-Stage
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /app

# Binary aus dem Builder-Image kopieren (Name = [[bin]] name = "main")
COPY --from=builder /app/target/release/main /app/app

ENV RUST_LOG=info
EXPOSE 8000
CMD ["/app/app"]