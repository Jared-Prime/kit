# syntax=docker/dockerfile:1
FROM dhi.io/alpine-base:3.24-alpine3.24-dev@sha256:266554e75cb00f88effe4048ba78b6f628d6a5ca67ac9e9727ae37a4a1299ce5 AS sandbox

RUN addgroup -g 1000 sandbox  && \
    adduser -D -u 1000 -G sandbox -h /home/agent -s /usr/bin/bash agent

FROM dhi.io/bash:5-alpine@sha256:e434f790cbc7f37a40eff837b5b7db6e3acd58e187276409987969d173dacb31 AS bash

FROM dhi.io/curl:8-alpine@sha256:8cb2542d1f7f0437c3c52ac9cc66c282114d791c9c75690295d965f7859e16a0 AS curl

FROM dhi.io/git:2-alpine@sha256:4b8028d5a4dbd0e6ae5208c10f262f06223da4dd6775565ab573da129c34a7dc AS git

FROM ghcr.io/j178/prek:0.5.11-alpine3.24@sha256:62e5379b34088c4e4ba098fc3e34352853c2fa55814209b86999b79cedae2c16 AS prek

FROM sandbox AS jq

RUN apk add --no-cache jq

FROM sandbox AS rp

RUN apk add --no-cache ripgrep

FROM sandbox AS memory

ARG CBM_VERSION=0.12.1
ARG TARGETARCH

RUN case "${TARGETARCH}" in \
      amd64) sha256=8c3d0341064301e78ecc84cf7348d4e2c6562a0f57448243ea560aaa34de36c1 ;; \
      arm64) sha256=ed0f1f548cd79b121c401c2e9f7841c189a001af26d3768368088c24f6a53533 ;; \
      *) echo "unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac && \
    wget -q -O /tmp/cbm.tar.gz \
      "https://github.com/DeusData/codebase-memory-mcp/releases/download/v${CBM_VERSION}/codebase-memory-mcp-linux-${TARGETARCH}-portable.tar.gz" && \
    echo "${sha256}  /tmp/cbm.tar.gz" | sha256sum -c - && \
    mkdir /tmp/cbm && \
    tar -xzf /tmp/cbm.tar.gz -C /tmp/cbm codebase-memory-mcp LICENSE THIRD_PARTY_NOTICES.md && \
    /tmp/cbm/codebase-memory-mcp --version | grep -q "${CBM_VERSION}"

FROM dhi.io/node:26-alpine-dev@sha256:16375cc385b69dbd63d19603d5ba671493294b4cd4d0e3d8132abb0562e29db5 AS node

ARG NODE_VERSION=26.13
ARG PNPM_VERSION=12.21.0
ARG TYPESCRIPT_VERSION=7.0.2

ENV SHELL=/usr/bin/bash
ENV PNPM_HOME=/opt/pnpm
ENV PATH="${PNPM_HOME}/bin:${PATH}"

# The 26-alpine-dev tag floats on minor, so a digest bump fails here until the claims are updated
RUN node --version | grep -q "^v${NODE_VERSION}\."

RUN npx --yes "get-pnpm@latest" "${PNPM_VERSION}" \
 && pnpm --version | grep -q "^${PNPM_VERSION}$"

RUN pnpm add -g "typescript@${TYPESCRIPT_VERSION}" \
 && tsc --version | grep -q "Version ${TYPESCRIPT_VERSION}$"

FROM ghcr.io/astral-sh/uv:0.13.9-alpine@sha256:788c243c482a0b16ef0e05c6e5bf7e4c2ba7f2e7ec04f05eb758a28607cfb652 AS uv

ARG PYTHON_VERSION=3.15

ENV UV_PYTHON_INSTALL_DIR=/opt/uv/python
ENV PATH="/opt/uv/bin:${PATH}"

RUN mkdir -p /opt/uv/bin && \
    cp "$(command -v uv)" "$(command -v uvx)" /opt/uv/bin/ && \
    uv python install "${PYTHON_VERSION}" && \
    uv python list --only-installed | grep -q "cpython-${PYTHON_VERSION}" && \
    uv pip uninstall --python "$(uv python find "${PYTHON_VERSION}")" --break-system-packages pip && \
    ! "$(uv python find "${PYTHON_VERSION}")" -m pip --version

FROM sandbox AS tools

ENV SHELL=/usr/bin/bash
ENV PNPM_HOME=/opt/pnpm
ENV UV_PYTHON_INSTALL_DIR=/opt/uv/python
ENV PATH="/opt/pnpm/bin:/opt/uv/bin:${PATH}"

COPY --from=bash /usr/lib/libreadline.so* /usr/lib/libncursesw.so* /usr/lib/
COPY --from=bash /bin/bash /usr/bin/bash
COPY --from=bash /bin/bash /bin/bash
COPY --from=curl /usr/lib/libcurl.so* /usr/lib/
COPY --from=curl /usr/lib/libnghttp2.so* /usr/lib/
COPY --from=curl /usr/lib/libcares.so* /usr/lib/
COPY --from=curl /usr/lib/libidn2.so* /usr/lib/
COPY --from=curl /usr/lib/libpsl.so* /usr/lib/
COPY --from=curl /usr/lib/libzstd.so* /usr/lib/
COPY --from=curl /usr/lib/libbrotlidec.so* /usr/lib/
COPY --from=curl /usr/lib/libbrotlicommon.so* /usr/lib/
COPY --from=curl /usr/lib/libunistring.so* /usr/lib/
COPY --from=curl /usr/bin/curl /usr/local/bin/curl
COPY --from=git /usr/bin/git /usr/local/bin/git
COPY --from=prek /usr/local/bin/prek /usr/local/bin/prek
COPY --from=jq /usr/lib/libjq.so* /usr/lib/
COPY --from=jq /usr/lib/libonig.so* /usr/lib/
COPY --from=jq /usr/bin/jq /usr/local/bin/jq
COPY --from=rp /usr/lib/libgcc_s.so* /usr/lib/
COPY --from=rp /usr/lib/libpcre2-8.so* /usr/lib/
COPY --from=rp /usr/bin/rg /usr/local/bin/rg
COPY --from=memory /tmp/cbm/codebase-memory-mcp /usr/local/bin/codebase-memory-mcp
COPY --from=node /usr/lib/libstdc++.so* /usr/lib/libgcc_s.so* /usr/lib/
COPY --from=node /usr/bin/node /usr/local/bin/node
COPY --from=node --chown=1000:1000 /opt/pnpm /opt/pnpm
COPY --from=uv --chown=1000:1000 /opt/uv /opt/uv

# sanity check copied binaries
ARG NODE_VERSION=26.13
ARG BASH_VERSION=5.3.9
ARG CURL_VERSION=8.23.0
ARG JQ_VERSION=1.8.2
ARG RG_VERSION=15.1.0
ARG GIT_VERSION=2.55.0
ARG PREK_VERSION=0.5.11
ARG CODEBASE_MEMORY_MCP_VERSION=0.12.1

RUN bash --version | grep -q "GNU bash, version ${BASH_VERSION}" && \
    curl --version | grep -q "curl ${CURL_VERSION}" && \
    git --version | grep -q "git version ${GIT_VERSION}" && \
    jq --version | grep -q "jq-${JQ_VERSION}" && \
    rg --version | grep -q "ripgrep ${RG_VERSION}" && \
    node --version | grep -q "^v${NODE_VERSION}\." && \
    prek --version | grep -q "prek ${PREK_VERSION}" && \
    codebase-memory-mcp --version | grep -q "codebase-memory-mcp ${CODEBASE_MEMORY_MCP_VERSION}"

ENTRYPOINT [ "bash" ]
