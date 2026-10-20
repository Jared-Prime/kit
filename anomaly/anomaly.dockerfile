# syntax=docker/dockerfile:1
FROM scratch AS config

COPY anomaly.jsonc /etc/opencode/opencode.jsonc

FROM node:24.22-alpine3.24@sha256:44fce696f38ba8c987c4db89954051000bbd05ffd8d8659ba15ed4a8602e937f

LABEL authors="Jared Davis"

ARG GIT_VERSION=2.54.0
ARG JQ_VERSION=1.8.2
ARG PNPM_VERSION=10.15.0
ARG TYPESCRIPT_VERSION=5.9.2

ENV COREPACK_HOME=/opt/corepack
ENV PNPM_HOME=/opt/pnpm
ENV PATH="${PNPM_HOME}:${PATH}"

RUN apk add bash "git~${GIT_VERSION}" "jq~${JQ_VERSION}" && \
    git --version | grep -q "^git version ${GIT_VERSION}$" && \
    jq --version | grep -q "^jq-${JQ_VERSION}$" && \
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
RUN pnpm add -g @opencode/cli@2.0.32 --allow-build=@opencode/cli && \
    test "$(opencode --version)" = "opencode v2.0.32"

COPY --from=config /etc/opencode/opencode.jsonc /etc/opencode/opencode.jsonc
COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
