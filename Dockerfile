FROM alpine:latest

MAINTAINER Jan Cajthaml <jan.cajthaml@gmail.com>

ENV S6_OVERLAY_VERSION v1.17.1.1
ENV GODNSMASQ_VERSION 0.9.8

RUN addgroup -S mongodb && \
    adduser -S -G mongodb mongodb

RUN apk add --no-cache --virtual linux-headers && \
    apk add --no-cache --virtual --update tar && \
    apk add --no-cache --virtual git && \
    apk add --no-cache --virtual curl && \
    apk add --no-cache --virtual tcl && \
    apk add --no-cache --virtual make && \
    apk add --no-cache --virtual gcc && \
    apk add --no-cache --virtual g++ && \
    apk add --no-cache --virtual scons

RUN curl -sSL https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz \
    | tar xvz --no-same-owner -C / --strip-components 1 -f - && \
    curl -sSL https://github.com/janeczku/go-dnsmasq/releases/download/${GODNSMASQ_VERSION}/go-dnsmasq-min_linux-amd64 -o /bin/go-dnsmasq && \
    chmod +x /bin/go-dnsmasq

ENV MONGO_VERSION r3.4.0

RUN mkdir -p /tmp/mongo-stable && cd /tmp/mongo-stable && \
    git clone git://github.com/mongodb/mongo.git --branch ${MONGO_VERSION} --single-branch --depth=1 .

RUN cd /tmp/mongo-stable && \
    scons core install -j2 --prefix=/usr/local --disable-warnings-as-errors

#apk del openssl-dev && \

RUN apk del linux-headers && \
    apk del curl && \
    apk del git && \
    apk del tcl && \
    apk del make && \
    apk del gcc && \
    apk del g++ && \
    apk del scons && \
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
