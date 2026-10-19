# syntax=docker/dockerfile:1
FROM node:24-slim@sha256:a5f4366e834695d5f363b920c104953a535d3a9864d1bdf74566a0ebe01daee5 AS build

ARG PNPM_VERSION=10.15.0
ARG TYPESCRIPT_VERSION=5.9.2

ENV COREPACK_HOME="/opt/corepack"
ENV PNPM_HOME="/opt/pnpm"
ENV PATH="${PNPM_HOME}:${PATH}"

RUN corepack enable \
 && corepack prepare "pnpm@${PNPM_VERSION}" --activate \
 && pnpm --version | grep -q "^${PNPM_VERSION}$"

RUN pnpm add -g "typescript@${TYPESCRIPT_VERSION}" \
 && tsc --version | grep -q "Version ${TYPESCRIPT_VERSION}$"

FROM scratch

ENV COREPACK_HOME="/home/agent/.cache/corepack"
ENV PNPM_HOME="/home/agent/.cache/pnpm"
ENV PATH="${PNPM_HOME}:/usr/local/bin:${PATH}"

COPY --from=build --chown=1000:1000 /usr/local /usr/local
COPY --from=build --chown=1000:1000 /opt/corepack /home/agent/.cache/corepack
COPY --from=build --chown=1000:1000 /opt/pnpm /home/agent/.cache/pnpm

ENTRYPOINT ["pnpm"]
CMD ["--version"]
