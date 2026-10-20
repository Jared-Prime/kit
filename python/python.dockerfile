# syntax=docker/dockerfile:1
FROM ghcr.io/astral-sh/uv:0.13.3@sha256:bee0a2a458fd956c5df7b8b4c5fed2257b0af34866e3da7b51db0be3acb375d1 AS uv

FROM python:alpine3.24@sha256:5aa3872d12a059e22fda84b7556a8d103dc9dff314d044d2d47d5785378c5856

LABEL authors="Jared Davis"

ARG GIT_VERSION=2.54.0
ARG JQ_VERSION=1.8.2

RUN apk add bash "git~${GIT_VERSION}" "jq~${JQ_VERSION}" && \
    git --version | grep -q "^git version ${GIT_VERSION}$" && \
    jq --version | grep -q "^jq-${JQ_VERSION}$" && \
    addgroup -g 1001 agent  && \
    adduser -D -u 1001 -G agent -h /home/agent -s /bin/bash agent

COPY --from=uv /uv /uvx /bin/

RUN uv --version | grep -q "uv 0.13.3"

WORKDIR /home/agent

USER 1001:1001

ENTRYPOINT ["uv"]
CMD ["--version"]
