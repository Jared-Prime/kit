# syntax=docker/dockerfile:1
ARG BASE=ghcr.io/jared-prime/kit-typescript:v1.4.0-pre

FROM scratch AS config

COPY guided-review /usr/share/kit/skills/guided-review

FROM ${BASE}

COPY --from=config /usr/share/kit/skills /usr/share/kit/skills
