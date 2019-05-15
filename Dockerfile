FROM golang:1.12.5-alpine3.9 AS builder

ARG GO_DEP_VERSION=0.5.2

# Install dependencies
RUN apk add --no-cache git curl ca-certificates

RUN curl --fail -L -o /usr/local/bin/dep https://github.com/golang/dep/releases/download/${GO_DEP_VERSION}/dep-linux-amd64 \
    && chmod a+x /usr/local/bin/dep

# Copy the code from the host and compile it
WORKDIR $GOPATH/src/github.com/connectedservices/ecs-exporter
COPY Gopkg.toml Gopkg.lock ./
RUN dep ensure --vendor-only
COPY . ./
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix nocgo -o /usr/local/bin/ecs-exporter ./cmd/ecs-exporter/


FROM golang:1.12.5-alpine3.9

COPY --from=builder /usr/local/bin/ecs-exporter /usr/local/bin/ecs-exporter
ENTRYPOINT ["/usr/local/bin/ecs-exporter"]
CMD ["--help"]
