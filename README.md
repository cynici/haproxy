# haproxy in docker

Key differences from the official [HAProxy](https://hub.docker.com/_/haproxy/) on Docker Hub:

- Uses [alpine](https://hub.docker.com/_/alpine/) as base image for its tiny footprint instead of debian:testing 
- Runs service as user *haproxy* in container instead of *root* using HAProxy configuration parameter *user*
- Included rsyslogd so that logs can be saved to a file and/or retransmitted to ELK, etc.
- No *bash*, use *sh* instead if necessary

The image is less than 20 MB!

If, however, you need to rewrite URLs in HTML response body, [HAProxy is not the right tool](http://serverfault.com/questions/336338/using-nginx-to-rewrite-urls-inside-outgoing-responses). Use [nginx](https://github.com/sickp/docker-alpine-nginx) instead.

## Usage

As usual, craft your own *haproxy.cfg*

For performance reason, HAProxy cannot log to a file directly. Logging is via either a separate local or remote syslog daemon. To log to a file, create a ENTRYPOINT script *docker-entrypoint.sh* and make it executable (*chmod ugo+x docker-entrypoint.sh*). 

This entrypoint script will start up a local syslog daemon, and by default, log all HAProxy traffic to */var/log/messages*. You can customize *rsyslogd*, e.g. log to multiple destination, etc. by crafting additional rsyslogd configuration and mount it into the container with VOLUMES as */etc/rsyslog.d/10-extraconfig.conf*

```
#!/bin/sh
set -ux
rm -f /var/run/rsyslogd.pid
rsyslogd
exec "$@"
```

Sample *haproxy.cfg*

```
haproxy:
  image: cheewai/haproxy
  ports:
    - "80:80"
    # If you want to proxy SSL, uncomment the line below
    #- "443:443"
  volumes:
    # If proxying SSL, you must supply all your certificate PEM(s)
    # in a directory e.g. 'ssl' and your haproxy.cfg lines should
    # reference /etc/ssl/private
    #- ./ssl:/etc/ssl/private
    - ./haproxy.cfg:/etc/haproxy/haproxy.cfg
    - ./docker-entrypoint.sh:/docker-entrypoint.sh:ro
  entrypoint:
    - /docker-entrypoint.sh
```
