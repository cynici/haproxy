FROM haproxy:alpine
LABEL maintainer "Cheewai Lai <clai@csir.co.za>"

# Obtained from Dockerfile in https://github.com/docker-library/haproxy
ARG LUA_VER=5.3
ARG HAP_HOME=/usr/local/share/lua/${LUA_VER}

RUN runDeps='curl rsyslog rsyslog-tls' \
 && apk add --update $runDeps \
 && echo 'http://nl.alpinelinux.org/alpine/edge/community' >>/etc/apk/repositories \
 && apk update \
 && apk add apk-tools lua${LUA_VER} unzip \
 && apk add --virtual .build-deps build-base luarocks${LUA_VER} openssl openssl-dev lua${LUA_VER}-dev \
 && luarocks-${LUA_VER} install luaossl \
 && curl -fsSL -o $HAP_HOME/http.lua https://raw.githubusercontent.com/haproxytech/haproxy-lua-http/master/http.lua \
 && curl -fsSL -o $HAP_HOME/json.lua https://raw.githubusercontent.com/rxi/json.lua/master/json.lua \
 && chmod 555 $HAP_HOME/*.lua \
 && apk del .build-deps \
 && rm -rf /var/cache/apk/*

RUN curl -fsSL -o /tmp/hla.zip https://github.com/haproxytech/haproxy-lua-acme/archive/master.zip \
 && unzip -x /tmp/hla.zip -d /usr/local/etc/haproxy

ADD docker-entrypoint-pre.sh /docker-entrypoint-pre.sh
ENTRYPOINT ["/docker-entrypoint-pre.sh"]
