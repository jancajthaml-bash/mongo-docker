FROM alpine:latest

MAINTAINER Jan Cajthaml <jan.cajthaml@gmail.com>

ENV S6_OVERLAY_VERSION v1.17.1.1
ENV GODNSMASQ_VERSION 0.9.8

RUN addgroup -S mongodb && \
    adduser -S -G mongodb mongodb

RUN apk add --no-cache --virtual linux-headers && \
    apk add --no-cache --virtual --update tar && \
    apk add --no-cache --virtual tcl && \
    apk add --no-cache --virtual curl && \
    apk add --no-cache --virtual build-base

RUN curl -sSL https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz \
    | tar xvz --no-same-owner -C / --strip-components 1 -f - && \
    curl -sSL https://github.com/janeczku/go-dnsmasq/releases/download/${GODNSMASQ_VERSION}/go-dnsmasq-min_linux-amd64 -o /bin/go-dnsmasq && \
    chmod +x /bin/go-dnsmasq

RUN curl -sSL https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-3.4.1.tgz | tar xvz --no-same-owner -C /usr/local --strip-components 1 --wildcards -f - \*/bin/\* && \
    rm -rf /usr/local/bin/mongosniff /usr/local/bin/mongoperf

RUN apk del linux-headers && \
    apk del tcl && \
    apk del curl && \
    apk del build-base && \
    rm -rf /var/cache/*

# Add the files
ADD etc /etc
ADD usr /usr

# Remove comment to lower size
RUN a=$(sed -e '/^[[:space:]]*$/d' -e '/^[[:space:]]*#/d' /etc/mongo.conf);echo "$a" > /etc/mongo.conf

# Local to broadcast
RUN sed -i -e 's/bind 127.0.0.1/bind 0.0.0.0/' /etc/mongo.conf

RUN mkdir -p /data && \
    mkdir -p /var/lib/mongodb && \
    mkdir -p /var/log/mongodb && \
    chown -R mongodb:mongodb /data #&& \
    #chown -R mongodb:mongodb /var/lib/mongodb && \
    #chown -R mongodb:mongodb /var/log/mongodb

VOLUME ["/data"]

# Expose the ports for mongo
EXPOSE 27017 28017

ENTRYPOINT ["/init"]
CMD []
