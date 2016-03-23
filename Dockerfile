FROM alpine
MAINTAINER Cheewai Lai <clai@csir.co.za>

RUN runDeps='ca-certificates haproxy rsyslog' HOME='/root' \
        && set -x \
        && apk add --update $runDeps \
	&& rm -rf /root/.gnupg \
        && rm -rf /var/cache/apk/* \
        ;
