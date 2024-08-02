FROM docker.redpanda.com/redpandadata/connect
# Arguments
ARG TARGETARCH
ARG PB_VERSION=0.22.18
ARG DUCKDB_VERSION=1.0.0

# Adding extra tools

# sq.io
RUN /bin/sh -c "$(curl -fsSL https://sq.io/install.sh)"


# download and unzip PocketBase
ADD https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/pocketbase_${PB_VERSION}_linux_amd64.zip /tmp/pb.zip
RUN unzip /tmp/pb.zip -d /pb/

# Install s3 service
go install github.com/seaweedfs/seaweedfs/weed@latest

# Install duckdb

# Selects correct DuckDB version based on the architecture and version
RUN if [ "$TARGETARCH" = "amd64" ]; then \
        export DUCKDB_URL="https://github.com/duckdb/duckdb/releases/download/v${DUCKDB_VERSION}/duckdb_cli-linux-amd64.zip"; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        export DUCKDB_URL="https://github.com/duckdb/duckdb/releases/download/v${DUCKDB_VERSION}/duckdb_cli-linux-aarch64.zip"; \
    else \
        echo "Arquitectura no soportada: $TARGETARCH"; \
        exit 1; \
    fi && \
    echo "Descargando desde $DUCKDB_URL" && \
    curl -L $DUCKDB_URL -o duckdb_cli.zip && \
    unzip duckdb_cli.zip -d /usr/local/bin && \
    rm duckdb_cli.zip

EXPOSE 8080
# start PocketBase
CMD ["/pb/pocketbase", "serve", "--http=0.0.0.0:8080"]
