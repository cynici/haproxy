# haproxy in docker

Key differences from the official [HAProxy](https://hub.docker.com/_/haproxy/) on Docker Hub:

- Uses [alpine](https://hub.docker.com/_/alpine/) as base image for its tiny footprint instead of debian:testing 
- Runs service as user *haproxy* in container instead of *root* Thanks to [tianon](https://github.com/tianon/gosu/) and [mendsley](https://github.com/mendsley/docker-alpine-gosu)
- No *bash*, use *sh* instead if necessary

The image is less than 20 MB!


## Usage

As usual, craft your own *haproxy.cfg*

To run haproxy as a non-root user as per [Docker recommendation](https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/), create a script and *chmod ugo+x*:

```
#!/bin/sh
set -ux
usermod -u $RUN_UID haproxy
exec gosu haproxy "$@"
```

[docker-compose](https://docs.docker.com/compose/compose-file/) is recommended for. So, here's a sample *docker-compose.yml* for reference. Replace *RUN_UID* with that of the user running the container.

```
haproxy:
  image: cheewai/haproxy
  # Comment the line below if you intend to run multiple instances
  # or set unique container name for each instance
  container_name: haproxy
  environment:
    - RUN_UID=1001
  ports:
    - "80:80"
    # If you want to proxy SSL, uncomment the line below
    - "443:443"
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
