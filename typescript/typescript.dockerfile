# syntax=docker/dockerfile:1
FROM node:26.12-alpine3.24@sha256:9bd229b644e391df00fb989efa732335aefc6170a05d8c163c5c8ca9870da401

LABEL authors="Jared Davis"

ARG PNPM_VERSION=10.15.0
ARG TYPESCRIPT_VERSION=5.9.2

ENV COREPACK_HOME=/opt/corepack
ENV PNPM_HOME=/opt/pnpm
ENV PATH="${PNPM_HOME}:${PATH}"

RUN apk add bash && \
    addgroup -g 1001 sandbox  && \
    adduser -D -u 1001 -G sandbox -h /home/agent -s /bin/bash agent && \
    mkdir -p "${COREPACK_HOME}" "${PNPM_HOME}" && \
    chown 1001:1001 "${COREPACK_HOME}" "${PNPM_HOME}" && \
    corepack enable

WORKDIR /home/agent

USER 1001:1001

RUN corepack prepare "pnpm@${PNPM_VERSION}" --activate \
 && pnpm --version | grep -q "^${PNPM_VERSION}$"

RUN pnpm add -g "typescript@${TYPESCRIPT_VERSION}" \
 && tsc --version | grep -q "Version ${TYPESCRIPT_VERSION}$"
