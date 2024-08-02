FROM alpine:3.20
# Arguments
ARG TARGETARCH
ARG PB_VERSION=0.22.18
ARG DUCKDB_VERSION=1.0.0

# Add GO
RUN apk add --no-cache git make musl-dev go curl unzip

# Configure Go
ENV GOROOT /usr/lib/go
ENV GOPATH /go
ENV PATH /go/bin:$PATH

# Variables ENV
ENV DUCKDB_URL=""
ENV BENTHOS_URL=""

RUN mkdir -p ${GOPATH}/src ${GOPATH}/bin

# sq.io
RUN /bin/sh -c "$(curl -fsSL https://sq.io/install.sh)"

# download and unzip PocketBase
ADD https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/pocketbase_${PB_VERSION}_linux_amd64.zip /tmp/pb.zip
RUN unzip /tmp/pb.zip -d /pb/

# Install s3 service
RUN go install github.com/seaweedfs/seaweedfs/weed@latest

# Install duckdb and  Benthos / Redpanda Connect
# Selects correct DuckDB version based on the architecture and version
RUN if [ "$TARGETARCH" = "amd64" ]; then \
        echo "Downloading for amd64"; \
        curl -L "https://github.com/duckdb/duckdb/releases/download/v${DUCKDB_VERSION}/duckdb_cli-linux-amd64.zip" -o duckdb_cli.zip; \
        curl -L "https://github.com/redpanda-data/redpanda/releases/latest/download/rpk-linux-amd64.zip" -o rpk-linux-download.zip; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        echo "Downloading for arm64"; \
        curl -L "https://github.com/duckdb/duckdb/releases/download/v${DUCKDB_VERSION}/duckdb_cli-linux-aarch64.zip" -o duckdb_cli.zip; \
        curl -L "https://github.com/redpanda-data/redpanda/releases/latest/download/rpk-linux-arm64.zip" -o rpk-linux-download.zip; \
    else \
        echo "Not supported architecture: $TARGETARCH"; \
        exit 1; \
    fi

RUN unzip duckdb_cli.zip -d /usr/local/bin
RUN unzip rpk-linux-download.zip -d ~/.local/bin/
RUN rm duckdb_cli.zip rpk-linux-download.zip

EXPOSE 8080
# start PocketBase
CMD ["/pb/pocketbase", "serve", "--http=0.0.0.0:8080"]
