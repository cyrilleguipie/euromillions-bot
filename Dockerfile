FROM rust:latest as builder

WORKDIR /usr/src/app
COPY . .

ENV SQLX_OFFLINE=true
RUN cargo install --path .

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y libssl-dev ca-certificates && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/cargo/bin/euromillions_bot /usr/local/bin/euromillions_bot

CMD ["euromillions_bot"]
