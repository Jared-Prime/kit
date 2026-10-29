# syntax=docker/dockerfile:1
FROM dhi.io/bash:5-alpine@sha256:a707212b3cedeb3241971658dba3f152d2d1a1cda5f7c4cc6f9582973b27a414 AS bash

FROM dhi.io/git:2-alpine@sha256:64816bd7a1f789b165217c834bfb8cfe2977af3c5d732edffd0e33569adb82c5 AS git

FROM ghcr.io/j178/prek:0.5.7-alpine3.24@sha256:15402f864b885e927891cd320eb711cf125d424c8a45f6837a55618fdfbe93a3 AS prek

FROM dhi.io/alpine-base:3.24-alpine3.24-dev@sha256:7182e0bc2f186386bb23bc0718508913450ba1876e93cf07e5e3cf263c4dbb63 AS extra

ARG CBM_VERSION=0.12.1
ARG TARGETARCH

RUN apk add --no-cache jq && \
    addgroup -g 1001 sandbox  && \
    adduser -D -u 1001 -G sandbox -h /home/agent -s /bin/bash agent

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


FROM dhi.io/node:26-alpine-dev@sha256:0614d22bcdfe1f5fbf985e68b455e61aefba8bc697894a6e91a8542a3e5f26b4 AS node

ARG PNPM_VERSION=12.15.0
ARG TYPESCRIPT_VERSION=7.0.2

ENV SHELL=/bin/bash
ENV PNPM_HOME=/opt/pnpm
ENV PATH="${PNPM_HOME}/bin:${PATH}"

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

FROM dhi.io/alpine-base:3.24@sha256:7b06d747fcb428a0699679955e903b13322c92c79d94ce94c108634f13a714f1

COPY --from=bash /usr/lib /usr/lib
COPY --from=bash /bin/bash /bin/bash
COPY --from=prek /usr/local/bin/prek /usr/local/bin/prek
COPY --from=git /usr/lib /usr/lib
COPY --from=git /usr/bin/git /usr/bin/git
COPY --from=node /usr/bin/node /usr/bin/node
COPY --from=node --chown=1001:1001 /opt/pnpm /opt/pnpm
COPY --from=uv --chown=1001:1001 /opt/uv /opt/uv
COPY --from=extra /etc/passwd /etc/passwd
COPY --from=extra /etc/group /etc/group
COPY --from=extra /usr/lib/libjq.so* /usr/lib/libonig.so* /usr/lib/
COPY --from=extra /usr/bin/jq /usr/bin/jq
COPY --from=extra --chmod=0755 /tmp/cbm/codebase-memory-mcp /usr/local/bin/codebase-memory-mcp
COPY --from=extra /tmp/cbm/LICENSE /tmp/cbm/THIRD_PARTY_NOTICES.md /usr/local/share/doc/codebase-memory-mcp/
COPY --from=extra --chown=1001:1001 /home/agent /home/agent
COPY skills/introspection /usr/share/kit/skills/introspection
COPY skills/codebase-memory /usr/share/kit/skills/codebase-memory

ENV SHELL=/bin/bash
ENV PNPM_HOME=/opt/pnpm
ENV UV_PYTHON_INSTALL_DIR=/opt/uv/python
ENV PATH="${PNPM_HOME}/bin:/opt/uv/bin:${PATH}"

WORKDIR /home/agent

USER 1001:1001

ENTRYPOINT [ "bash" ]
