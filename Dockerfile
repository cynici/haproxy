FROM alpine
MAINTAINER Cheewai Lai <clai@csir.co.za>

ARG S6_OVERLAY_VERSION=v1.17.2.0

RUN runDeps='ca-certificates haproxy rsyslog curl' HOME='/root' && \
 set -x && \
 apk add --update $runDeps && \
 curl -sSL https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz \
 | tar xfz - -C / && \
 rm -rf /root/.gnupg && \
 rm -rf /var/cache/apk/*

# sed -i 's/^\(.*imklog.*\)/#\1/' /etc/rsyslog.conf

COPY s6-rsyslog /etc/services.d/rsyslog
ENTRYPOINT ["/init"]
CMD ["haproxy", "-db", "-f", "/etc/haproxy/haproxy.cfg"]
