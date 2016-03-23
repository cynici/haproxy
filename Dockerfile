FROM alpine
MAINTAINER Cheewai Lai <clai@csir.co.za>

# 036A9C25BF357DD4 - Tianon Gravi <tianon@tianon.xyz>
#   http://pgp.mit.edu/pks/lookup?op=vindex&search=0x036A9C25BF357DD4
ENV GOSU_VERSION="1.7" \
    GOSU_DOWNLOAD_URL="https://github.com/tianon/gosu/releases/download/1.7/gosu-amd64" \
    GOSU_DOWNLOAD_SIG="https://github.com/tianon/gosu/releases/download/1.7/gosu-amd64.asc" \
    GOSU_DOWNLOAD_KEY="0x036A9C25BF357DD4"

RUN buildDeps='curl gnupg' runDeps='ca-certificates haproxy rsyslog shadow' HOME='/root' \
        && echo http://nl.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories \
        && set -x \
        && apk add --update $buildDeps $runDeps \
	&& gpg-agent --daemon \
	&& gpg --keyserver pgp.mit.edu --recv-keys $GOSU_DOWNLOAD_KEY \
	&& echo "trusted-key $GOSU_DOWNLOAD_KEY" >> /root/.gnupg/gpg.conf \
	&& curl -sSL "$GOSU_DOWNLOAD_URL" > gosu-amd64 \
	&& curl -sSL "$GOSU_DOWNLOAD_SIG" > gosu-amd64.asc \
	&& gpg --verify gosu-amd64.asc \
	&& rm -f gosu-amd64.asc \
	&& mv gosu-amd64 /usr/bin/gosu \
	&& chmod +x /usr/bin/gosu \
        && apk del --purge $buildDeps \
	&& rm -rf /root/.gnupg \
        && rm -rf /var/cache/apk/* \
        ;

CMD haproxy -db -f /etc/haproxy/haproxy.cfg
