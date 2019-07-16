FROM alpine:latest

LABEL maintainer="Unifio, Inc. <support@unifio.com>"

RUN apk add --update build-base go fuse git bash coreutils \
    && mkdir -p /go/src/github.com/keybase/ \
    && export GOPATH=/go \
    && cd /go/src/github.com/keybase \
    && git clone https://github.com/keybase/client.git \
    && go install github.com/keybase/client/go/keybase/ \
    && go install github.com/keybase/client/go/kbfs/kbfsfuse \
    && apk del build-base go git \
    && rm -rf /var/cache/apk/* \
    && rm -rf /go/src/

COPY build-docker-entrypoint.sh /

RUN mkdir -p /opt/keybase/bin
COPY wait-for-flush.sh /opt/keybase/bin/
RUN chmod +x /opt/keybase/bin/*

ENTRYPOINT ["/build-docker-entrypoint.sh"]
