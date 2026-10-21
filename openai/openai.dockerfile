# syntax=docker/dockerfile:1
FROM scratch AS config

COPY openai.toml /etc/codex/config.toml

FROM node:24.22-alpine3.24@sha256:44fce696f38ba8c987c4db89954051000bbd05ffd8d8659ba15ed4a8602e937f

LABEL authors="Jared Davis"

ARG GIT_VERSION=2.54.0
ARG JQ_VERSION=1.8.2
ARG PNPM_VERSION=10.15.0
ARG TYPESCRIPT_VERSION=5.9.2
ARG RIPGREP_VERSION=15.1.0-r0

ENV COREPACK_HOME=/opt/corepack
ENV PNPM_HOME=/opt/pnpm
ENV PATH="${PNPM_HOME}:${PATH}"
ENV NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

RUN apk update && \
    apk add bash ca-certificates "git~${GIT_VERSION}" "jq~${JQ_VERSION}" "ripgrep=${RIPGREP_VERSION}" && \
    git --version | grep -q "^git version ${GIT_VERSION}$" && \
    jq --version | grep -q "^jq-${JQ_VERSION}$" && \
    addgroup -g 1001 sandbox  && \
    adduser -D -u 1001 -G sandbox -h /home/agent -s /bin/bash agent && \
    mkdir -p "${COREPACK_HOME}" "${PNPM_HOME}" && \
    chown 1001:1001 "${COREPACK_HOME}" "${PNPM_HOME}" && \
    corepack enable

# Disables the emSign ECC Root CA - G3 explicitly (Oct 2026, GHSA-hq85-5cpj-mr62)
# Remove this step once the upstream package ships the fix on its own.
RUN sed -i -e 's|^mozilla/emSign_ECC_Root_CA_-_G3\.crt|!&|' /etc/ca-certificates.conf && \
    grep -q "^!mozilla/emSign_ECC_Root_CA_-_G3\.crt$" /etc/ca-certificates.conf && \
    update-ca-certificates

WORKDIR /home/agent

USER 1001:1001

RUN corepack prepare "pnpm@${PNPM_VERSION}" --activate \
 && pnpm --version | grep -q "^${PNPM_VERSION}$"

RUN pnpm add -g "typescript@${TYPESCRIPT_VERSION}" \
 && tsc --version | grep -q "Version ${TYPESCRIPT_VERSION}$"

RUN pnpm add -g @openai/codex@0.162.1 --allow-build=@openai/codex && \
    test "$(codex --version)" = "codex-cli 0.162.1"

# Codex bundles rg build requiring a glibc loader
# Replace the Codex bundled rg build with the Alpine package
RUN rg="$(find "${PNPM_HOME}" -path '*/codex-path/rg' -type f -print -quit)" && \
    test -n "${rg}" && \
    rm "${rg}"

COPY --from=config /etc/codex/config.toml /etc/codex/config.toml
COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
