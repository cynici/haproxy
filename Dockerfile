FROM haproxy:alpine
LABEL maintainer "Cheewai Lai <clai@csir.co.za>"

RUN runDeps='curl rsyslog rsyslog-tls' \
 && apk add --update $runDeps \
 && rm -rf /var/cache/apk/*

ADD docker-entrypoint-pre.sh /docker-entrypoint-pre.sh
ENTRYPOINT ["/docker-entrypoint-pre.sh"]
