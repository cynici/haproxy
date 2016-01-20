FROM alpine
MAINTAINER Cheewai Lai <clai@csir.co.za>

RUN set -x \
        && apk update \
        && apk add ca-certificates haproxy \
	&& rm -rf /root/.gnupg \
	&& rm -rf /var/cache/apk/* \
	;
