FROM alpine
MAINTAINER Cheewai Lai <clai@csir.co.za>

RUN runDeps='ca-certificates haproxy rsyslog shadow' HOME='/root' \
        && echo http://nl.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories \
        && set -x \
        && apk add --update $runDeps \
	&& rm -rf /root/.gnupg \
        && rm -rf /var/cache/apk/* \
        ;
