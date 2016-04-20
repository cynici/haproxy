# haproxy in docker

Key differences from the official [HAProxy](https://hub.docker.com/_/haproxy/) on Docker Hub:

- Uses [alpine](https://hub.docker.com/_/alpine/) as base image for its tiny footprint instead of debian:testing 
- Runs service as user *haproxy* in container instead of *root* as set by HAProxy configuration parameter *user*
- Includes rsyslogd so that logs can be saved to a file and/or retransmitted to ELK, etc.
- No *bash*, use *sh* instead if necessary
- Uses [s6](http://skarnet.org/software/s6/) to ensure liveness of rsyslogd and ensure proper signal propagation

The image is less than 20 MB!

If, however, you need to rewrite URLs in HTML response body, [HAProxy is not the right tool](http://serverfault.com/questions/336338/using-nginx-to-rewrite-urls-inside-outgoing-responses). Use [nginx](https://github.com/sickp/docker-alpine-nginx) instead.

For performance reason, HAProxy does not log to file on its own. Logging is via either a local or remote syslog daemon e.g. rsyslogd etc. That's why this docker image has included *rsyslogd* and  *s6*. The use of *rsyslogd* and *s6* is optional.

*s6* may be used to ensure signals are propagated, defunct processes are reaped, processes restarted if necessary.

By default, *rsyslogd* saved HAProxy logs to */var/log/messages*. You can customize *rsyslogd*, e.g. log to multiple destination, etc. by crafting additional rsyslogd configuration and mount it into the container with VOLUMES as */etc/rsyslog.d/10-extraconfig.conf*


## Usage

As usual, craft your own *haproxy.cfg*. Next, create a *docker-compose.yml* based on the example below. 

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


### HAProxy alone without running rsyslogd

In this case you don't really need s6. The container exits if HAProxy dies. You can compensate for this adding *restart: always* option to *docker-compose.yml* so that the container may be restarted by the Docker daemon.


### HAProxy with rsyslogd, without s6

*s6* does add slight delay to container startup/shutdown. Without it, you lose the ability to ensure that *rsyslogd* remains alive. The container exits if HAProxy dies. You can compensate for this adding *restart: always* option to *docker-compose.yml* so that the container may be restarted by the Docker daemon.

- Create *docker-entrypoint.sh* like this:

```
#!/bin/sh
set -ux
rm -f /var/run/rsyslogd.pid
rsyslogd
exec "$@"
```
- chmod 755 docker-entrypoint.sh
- Add item *- ./docker-entrypoint.sh:/docker-entrypoint.sh* to *volumes* list in *docker-compose.yml*
- Add *entrypoint: /docker-compose.yml* to *docker-compose.yml*


### HAProxy with rsyslogd and s6

- Add *entrypoint: /init* to *docker-compose.yml*

In doing so, */etc/services.d/rsyslog/run* script already present in the Docker image will be executed automatically by *s6* to bring up *rsyslogd* when the container comes up. *s6* also re-runs the script in the unlikely event that *rsyslogd* dies.


## References

* How to use s6 in a container [https://blog.tutum.co/2015/05/20/s6-made-easy-with-the-s6-overlay/]

* What are s6 services [http://skarnet.org/software/s6/servicedir.html]

* Add s6 to docker image [https://github.com/just-containers/s6-overlay]
