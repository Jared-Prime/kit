# syntax=docker/dockerfile:1
FROM dhi.io/alpine-base:3.24-alpine3.24-dev@sha256:7182e0bc2f186386bb23bc0718508913450ba1876e93cf07e5e3cf263c4dbb63 AS sandbox

RUN addgroup -g 1000 sandbox  && \
    adduser -D -u 1000 -G sandbox -h /home/agent -s /usr/bin/bash agent

FROM dhi.io/bash:5-alpine@sha256:280d2be0aeba1d9f7d83d69db9478be55c1c9d42b416ce2128ff2684c2bedf5e AS bash

FROM dhi.io/docker-dind:29-alpine@sha256:37c079c2442c0ac74bee326ea61641eaa496cad5dfeee11e8cc18bdfe96033b9 AS docker

FROM sandbox

COPY --from=bash /usr/lib/libreadline.so* /usr/lib/libncursesw.so* /usr/lib/
COPY --from=bash /bin/bash /usr/bin/bash
COPY --from=bash /bin/bash /bin/bash
COPY --from=docker /usr/bin/docker /usr/local/bin/docker

ARG DOCKER_VERSION=29.9.2
ARG BASH_VERSION=5.3.9

RUN bash --version | grep -q "GNU bash, version ${BASH_VERSION}" && \
    docker --version | grep -q "Docker version ${DOCKER_VERSION}"

ENTRYPOINT ["bash"]
