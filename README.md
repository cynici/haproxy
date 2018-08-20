# haproxy+rsyslog on alpine

Key differences from the official [HAProxy](https://hub.docker.com/_/haproxy/) on Docker Hub:

- Includes [haproxy-lua-acme](https://github.com/haproxytech/haproxy-lua-acme) in `/usr/local/etc/haproxy/haproxy-lua-acme-master/` described in [this blog article](https://www.haproxy.com/blog/lets-encrypt-acme2-for-haproxy/)
- Runs as user *haproxy* instead of *root* as set by HAProxy configuration parameter *user* by setting `RUNUSER_UID` environment variable to the UID value of the actual user outside the container. Optional.
- Includes rsyslog so that logs can be saved to a file and/or retransmitted to [Graylog](https://marketplace.graylog.org/addons?tag=haproxy), [Elasticsearch-Logstash-Kibana](https://www.elastic.co/guide/en/beats/metricbeat/current/metricbeat-module-haproxy.html), etc.
- No *bash*, use *sh* instead
- Not using [s6-overlay](http://skarnet.org/software/s6/) anymore because the official base image already includes `haproxy-systemd-wrapper` which propagates signals properly
- ~Uses [s6](http://skarnet.org/software/s6/) to ensure liveness of rsyslog and ensure proper signal propagation~

The image is less than ~20~ 30 MB!

If, however, you need to rewrite URLs in HTML response body, [HAProxy is not the right tool](http://serverfault.com/questions/336338/using-nginx-to-rewrite-urls-inside-outgoing-responses). Use [nginx](https://github.com/sickp/docker-alpine-nginx) instead.

For performance reason, HAProxy does not log to file on its own. Logging is via either a local or remote syslog daemon e.g. rsyslog etc. That's why this docker image has included *rsyslog*.

By default, *rsyslog* saved HAProxy logs to */var/log/messages*. You can customize *rsyslogd*, e.g. log to multiple destination, etc. by crafting additional rsyslogd configuration and mount it into the container with VOLUMES as */etc/rsyslog.d/10-extraconfig.conf*


## Usage

As usual, craft your own *haproxy.cfg*. Next, create a *docker-compose.yml* based on the example below. 

```
version: '2'
services:
  haproxy:
    image: cheewai/haproxy
    environment:
      RUNUSER_UID: 1001
      RUNUSER_HOME: /etc/haproxy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      # If proxying SSL, you must supply all your certificate PEM(s)
      # in a directory e.g. 'ssl' and your haproxy.cfg lines should
      # reference /etc/ssl/private
      #- ./ssl:/etc/ssl/private
      - ./haproxy.cfg:/etc/haproxy/haproxy.cfg
    restart: on-failure:5
```

### To test haproxy.cfg

When testing, you would want the haproxy container to test a new configuration file and exit right away. To do that, adapt your `docker-compose.yml` as follows:

```
version: '2'
services:
  haproxy:
    image: cheewai/haproxy
    environment:
      RUNUSER_UID: 1001
      RUNUSER_HOME: /etc/haproxy
    volumes:
      # If proxying SSL, you must supply all your certificate PEM(s)
      # in a directory e.g. 'ssl' and your haproxy.cfg lines should
      # reference /etc/ssl/private
      #- ./ssl:/etc/ssl/private
      - ${CFG}:/etc/haproxy/haproxy.cfg:ro
    # Specify the full pathname instead of just 'haproxy' to bypass haproxy-systemd-wrapper intended for daemon-mode
    command: ["/usr/local/sbin/haproxy", "-c", "-f", "/etc/haproxy/haproxy.cfg"]
    restart: never
```

Then you can validate your new configuration like so:

```
CFG=/path/to/new/haproxy.cfg docker-compose run --rm -T haproxy
```


## Where to find letsencrypt-x3-ca-chain.pem

Read *Comments* section in https://www.haproxy.com/blog/lets-encrypt-acme2-for-haproxy/

At the time of writing, you concatenate these files:

- [letsencryptauthorityx3.pem.txt](https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem.txt)
- [lets-encrypt-x3-cross-signed.pem.txt](https://letsencrypt.org/certs/letsencryptauthorityx3.pem.txt)
- [isrgrootx1.pem.txt](https://letsencrypt.org/certs/isrgrootx1.pem.txt)


## References

* How to use s6 in a container [https://blog.tutum.co/2015/05/20/s6-made-easy-with-the-s6-overlay/]

* What are s6 services [http://skarnet.org/software/s6/servicedir.html]

* Add s6 to docker image [https://github.com/just-containers/s6-overlay]
