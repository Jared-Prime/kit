# syntax=docker/dockerfile:1
FROM scratch AS config

COPY anomaly.jsonc /etc/opencode/opencode.jsonc

FROM node:26.12-alpine3.24@sha256:40cd011b55415bc894e45b02fdd5a5dfde056921b7d23a64c74f80497af48797

LABEL authors="Jared Davis"

ARG GIT_VERSION=2.54.0
ARG JQ_VERSION=1.8.2
ARG PNPM_VERSION=12.15.0
ARG NPM_VERSION=12.2.1
ARG TYPESCRIPT_VERSION=7.0.2

ENV SHELL=/bin/bash
ENV PNPM_HOME=/opt/pnpm
ENV PATH="${PNPM_HOME}/bin:${PATH}"
ENV NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

RUN apk add --no-cache bash ca-certificates "git~${GIT_VERSION}" "jq~${JQ_VERSION}" && \
    git --version | grep -q "^git version ${GIT_VERSION}$" && \
    jq --version | grep -q "^jq-${JQ_VERSION}$" && \
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
RUN pnpm add -g @opencode/cli@2.0.32 --allow-build=@opencode/cli && \
    test "$(opencode --version)" = "opencode v2.0.32"

COPY --from=config /etc/opencode/opencode.jsonc /etc/opencode/opencode.jsonc
COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
