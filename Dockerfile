# syntax=docker/dockerfile:1
FROM dhi.io/alpine-base:3.24-alpine3.24-dev@sha256:7182e0bc2f186386bb23bc0718508913450ba1876e93cf07e5e3cf263c4dbb63 AS sandbox

RUN addgroup -g 1000 sandbox  && \
    adduser -D -u 1000 -G sandbox -h /home/agent -s /usr/bin/bash agent

FROM dhi.io/bash:5-alpine@sha256:a707212b3cedeb3241971658dba3f152d2d1a1cda5f7c4cc6f9582973b27a414 AS bash

FROM dhi.io/git:2-alpine@sha256:64816bd7a1f789b165217c834bfb8cfe2977af3c5d732edffd0e33569adb82c5 AS git

FROM ghcr.io/j178/prek:0.5.7-alpine3.24@sha256:15402f864b885e927891cd320eb711cf125d424c8a45f6837a55618fdfbe93a3 AS prek

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

FROM dhi.io/node:26-alpine-dev@sha256:4f971dcdc1fdf59f9d3e84dbd529690c2d15f75ae898fb310acad9c12d7bbdf9 AS node

ARG NODE_VERSION=26.13
ARG PNPM_VERSION=12.15.0
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

FROM ghcr.io/astral-sh/uv:0.13.6-alpine@sha256:95f501aef734a5aaf167ff0640e02f215dcc7043ff48685de70328e5c55a57b0 AS uv

ARG PYTHON_VERSION=3.14

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
COPY --from=git /usr/bin/git /usr/local/bin/git
COPY --from=prek /usr/local/bin/prek /usr/local/bin/prek
COPY --from=jq /usr/lib/libjq.so* /usr/lib/
COPY --from=jq /usr/lib/libonig.so* /usr/lib/
COPY --from=jq /usr/bin/jq /usr/local/bin/jq
COPY --from=rp /usr/lib/libpcre2-8.so* /usr/lib/
COPY --from=rp /usr/bin/rg /usr/local/bin/rg
COPY --from=memory /tmp/cbm/codebase-memory-mcp /usr/local/bin/codebase-memory-mcp
COPY --from=node /usr/lib/libstdc++.so* /usr/lib/libgcc_s.so* /usr/lib/
COPY --from=node /usr/bin/node /usr/local/bin/node
COPY --from=node --chown=1000:1000 /opt/pnpm /opt/pnpm
COPY --from=uv --chown=1000:1000 /opt/uv /opt/uv

FROM tools AS opencode

ENV SHELL=/usr/bin/bash
ENV PNPM_HOME=/opt/pnpm
ENV PATH="${PNPM_HOME}/bin:${PATH}"

RUN pnpm add -g @opencode/cli@2.0.32 --allow-build=@opencode/cli && \
    test "$(opencode --version)" = "opencode v2.0.32"

WORKDIR /home/agent
USER 1000:1000

ENTRYPOINT [ "opencode" ]

FROM tools AS claude

ENV SHELL=/usr/bin/bash
ENV PNPM_HOME=/opt/pnpm
ENV PATH="${PNPM_HOME}/bin:${PATH}"

RUN pnpm add -g @anthropic-ai/claude-code@2.1.312 --allow-build=@anthropic-ai/claude-code && \
    test "$(claude --version)" = "2.1.312 (Claude Code)"

WORKDIR /home/agent
USER 1000:1000

ENTRYPOINT [ "claude" ]

FROM tools AS codex

ENV SHELL=/usr/bin/bash
ENV PNPM_HOME=/opt/pnpm
ENV PATH="${PNPM_HOME}/bin:${PATH}"

RUN pnpm add -g @openai/codex@0.165.0 --allow-build=@openai/codex && \
    test "$(codex --version)" = "codex-cli 0.165.0"

# Codex bundles an rg build requiring a glibc loader
# Remove it so the Alpine ripgrep package (copied into the final stage) is used
RUN rg="$(find "${PNPM_HOME}" -path '*/codex-path/rg' -type f -print -quit)" && \
    test -n "${rg}" && \
    rm "${rg}"

WORKDIR /home/agent
USER 1000:1000

ENTRYPOINT [ "codex" ]

# final layer - tools only by default
FROM tools

ENV SHELL=/bin/bash
ENV PNPM_HOME=/opt/pnpm
ENV PATH="${PNPM_HOME}/bin:${PATH}"

WORKDIR /home/agent
USER 1000:1000

ENTRYPOINT [ "bash" ]
