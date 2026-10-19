# syntax=docker/dockerfile:1
ARG BASE=ghcr.io/jared-prime/kit-typescript:v1.4.0-pre

FROM ${BASE}

USER root

RUN apk add --no-cache github-cli

USER 1001:1001

ENTRYPOINT ["gh"]
