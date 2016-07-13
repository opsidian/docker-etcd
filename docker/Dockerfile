FROM opsidian/alpine-base:latest

ENV ETCD_VERSION=v3.0.2

RUN \
    echo "Install Etcd" \
    && cd /tmp \
    && curl -sSLO https://github.com/coreos/etcd/releases/download/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz \
    && tar xzvf etcd-${ETCD_VERSION}-linux-amd64.tar.gz \
    && mv etcd-${ETCD_VERSION}-linux-amd64/etcd* /bin/ \
    && mkdir -p /data \
    && chmod 0700 /data \
    && chown app:app /data \

    && echo "Clean up" \
    && rm -rf /tmp/*

COPY opsidian-release /etc/opsidian-release

EXPOSE 2379 2380

VOLUME ["/data"]

CMD ["/bin/etcd", "-data-dir=/data"]

ENV ETCD_LISTEN_PEER_URLS=http://0.0.0.0:2380 \
    ETCD_LISTEN_CLIENT_URLS=http://0.0.0.0:2379
