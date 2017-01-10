FROM alpine:latest
MAINTAINER Cheewai Lai <clai@csir.co.za>

ARG S6_OVERLAY_VERSION=v1.18.1.5

RUN runDeps='ca-certificates haproxy@edge rsyslog curl' HOME='/root' && \
 set -x && \
 echo '@edge http://nl.alpinelinux.org/alpine/edge/main' >>/etc/apk/repositories && \
 echo '@testing http://nl.alpinelinux.org/alpine/edge/testing' >>/etc/apk/repositories && \
 apk add --update $runDeps && \
 curl -k -sSL https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz \
 | tar xfz - -C / && \
 rm -rf /root/.gnupg && \
 rm -rf /var/cache/apk/*

COPY s6-rsyslog /etc/services.d/rsyslog
CMD ["haproxy", "-db", "-f", "/etc/haproxy/haproxy.cfg"]
