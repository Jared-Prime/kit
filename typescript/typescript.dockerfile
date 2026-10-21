# syntax=docker/dockerfile:1
FROM node:26.12-alpine3.24@sha256:9bd229b644e391df00fb989efa732335aefc6170a05d8c163c5c8ca9870da401

LABEL authors="Jared Davis"

ARG PNPM_VERSION=12.14.0
ARG TYPESCRIPT_VERSION=5.9.2

ENV SHELL=/bin/bash
ENV PNPM_HOME=/opt/pnpm
ENV PATH="${PNPM_HOME}/bin:${PATH}"

RUN apk add bash && \
    addgroup -g 1001 sandbox  && \
    adduser -D -u 1001 -G sandbox -h /home/agent -s /bin/bash agent && \
    mkdir -p "${PNPM_HOME}" && \
    chown 1001:1001 "${PNPM_HOME}"

WORKDIR /home/agent

USER 1001:1001

RUN npx --yes "get-pnpm@latest" "${PNPM_VERSION}" \
 && pnpm --version | grep -q "^${PNPM_VERSION}$"

RUN pnpm add -g "typescript@${TYPESCRIPT_VERSION}" \
 && tsc --version | grep -q "Version ${TYPESCRIPT_VERSION}$"
