FROM docker.redpanda.com/redpandadata/connect

# Adding extra tools

# sq.io
RUN /bin/sh -c "$(curl -fsSL https://sq.io/install.sh)"

# pocketbase
ARG PB_VERSION=0.22.18

# download and unzip PocketBase
ADD https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/pocketbase_${PB_VERSION}_linux_amd64.zip /tmp/pb.zip
RUN unzip /tmp/pb.zip -d /pb/

# install s3 service
go install github.com/seaweedfs/seaweedfs/weed@latest

EXPOSE 8080
# start PocketBase
CMD ["/pb/pocketbase", "serve", "--http=0.0.0.0:8080"]
