# syntax=docker/dockerfile:1

FROM golang:1.26.5-alpine AS build

WORKDIR /src

# Download modules separately so source changes can reuse the module cache.
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build \
    -trimpath \
    -ldflags="-s -w" \
    -o /out/alps \
    ./cmd/alps

FROM alpine:3.22

RUN apk add --no-cache ca-certificates tzdata wget \
    && addgroup -S -g 10001 alps \
    && adduser -S -D -H -u 10001 -G alps alps

WORKDIR /app

COPY --from=build --chown=alps:alps /out/alps /usr/local/bin/alps
COPY --chown=alps:alps deploy/alps-config.toml /etc/alps/config.toml

USER 10001:10001

EXPOSE 1323

ENTRYPOINT ["/usr/local/bin/alps"]
CMD ["-config", "/etc/alps/config.toml"]
