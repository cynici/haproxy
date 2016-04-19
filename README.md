# haproxy in docker

Key differences from the official [HAProxy](https://hub.docker.com/_/haproxy/) on Docker Hub:

- Uses [alpine](https://hub.docker.com/_/alpine/) as base image for its tiny footprint instead of debian:testing 
- Runs service as user *haproxy* in container instead of *root* as set by HAProxy configuration parameter *user*
- Includes rsyslogd so that logs can be saved to a file and/or retransmitted to ELK, etc.
- No *bash*, use *sh* instead if necessary
- Uses [s6](http://skarnet.org/software/s6/) to ensure liveness of rsyslogd and ensure proper signal propagation

The image is less than 20 MB!

If, however, you need to rewrite URLs in HTML response body, [HAProxy is not the right tool](http://serverfault.com/questions/336338/using-nginx-to-rewrite-urls-inside-outgoing-responses). Use [nginx](https://github.com/sickp/docker-alpine-nginx) instead.

## Usage

As usual, craft your own *haproxy.cfg*

For performance reason, HAProxy cannot log to a file directly. Logging is via either a separate local or remote syslog daemon. That's why this docker image has included *rsyslogd* and uses *s6* to keep it alive.

By default, HAProxy logs are saved to */var/log/messages*. You can customize *rsyslogd*, e.g. log to multiple destination, etc. by crafting additional rsyslogd configuration and mount it into the container with VOLUMES as */etc/rsyslog.d/10-extraconfig.conf*

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
```

## References

* How to use s6 in a container [https://blog.tutum.co/2015/05/20/s6-made-easy-with-the-s6-overlay/]

* What are s6 services [http://skarnet.org/software/s6/servicedir.html]

* Add s6 to docker image [https://github.com/just-containers/s6-overlay]
