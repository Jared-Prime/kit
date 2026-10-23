# syntax=docker/dockerfile:1
FROM node:26.12-alpine3.24@sha256:40cd011b55415bc894e45b02fdd5a5dfde056921b7d23a64c74f80497af48797

LABEL authors="Jared Davis"

ARG PNPM_VERSION=12.15.0
ARG NPM_VERSION=12.2.1
ARG TYPESCRIPT_VERSION=7.0.2

ENV SHELL=/bin/bash
ENV PNPM_HOME=/opt/pnpm
ENV PATH="${PNPM_HOME}/bin:${PATH}"

RUN apk add --no-cache bash && \
    addgroup -g 1001 sandbox  && \
    adduser -D -u 1001 -G sandbox -h /home/agent -s /bin/bash agent && \
    mkdir -p "${PNPM_HOME}" && \
    chown 1001:1001 "${PNPM_HOME}"

RUN npm install -g "npm@${NPM_VERSION}" \
 && npm --version | grep -q "^${NPM_VERSION}$"

WORKDIR /home/agent

USER 1001:1001

RUN npx --yes "get-pnpm@latest" "${PNPM_VERSION}" \
 && pnpm --version | grep -q "^${PNPM_VERSION}$"

RUN pnpm add -g "typescript@${TYPESCRIPT_VERSION}" \
 && tsc --version | grep -q "Version ${TYPESCRIPT_VERSION}$"
