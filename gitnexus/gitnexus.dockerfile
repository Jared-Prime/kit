# syntax=docker/dockerfile:1
FROM ghcr.io/astral-sh/uv:0.13.5-alpine@sha256:6ba9c830aa848d21e1e9d8028ae01ed02b08980b25aeabef9a6683c5743c6d0f AS uv

# Build stage: compiles gitnexus's native modules. Nothing here ships except
# /opt/pnpm, so the toolchain, uv, and Python stay out of the mixin overlay.
FROM node:26.12-alpine3.24@sha256:40cd011b55415bc894e45b02fdd5a5dfde056921b7d23a64c74f80497af48797 AS build

ARG PNPM_VERSION=12.15.0
ARG NPM_VERSION=12.2.1
ARG GIT_NEXUS_VERSION=1.6.12
ARG PYTHON_VERSION=3.14

ENV PNPM_HOME=/opt/pnpm
ENV UV_PYTHON_INSTALL_DIR=/opt/uv/python
ENV PATH="${PNPM_HOME}/bin:/opt/uv/bin:${PATH}"
# Skips gitnexus's vendored grammars (Dart, Proto, Swift, Kotlin, Zig); the
# 10 core languages are regular dependencies and are unaffected.
ENV GITNEXUS_SKIP_OPTIONAL_GRAMMARS=1

# make/g++: the core tree-sitter binding has no linux-musl-arm64 prebuild and
# falls back to node-gyp. Python for node-gyp comes from uv, matching the
# python mixin, rather than apk.
RUN apk add --no-cache bash make g++ && \
    addgroup -g 1001 sandbox && \
    adduser -D -u 1001 -G sandbox -h /home/agent -s /bin/bash agent && \
    mkdir -p "${PNPM_HOME}" "${UV_PYTHON_INSTALL_DIR}" /opt/uv/bin && \
    chown -R 1001:1001 "${PNPM_HOME}" /opt/uv

COPY --from=uv /usr/local/bin/uv /usr/local/bin/uvx /opt/uv/bin/

RUN npm install -g "npm@${NPM_VERSION}" \
 && npm --version | grep -q "^${NPM_VERSION}$"

WORKDIR /home/agent

USER 1001:1001

RUN npx --yes "get-pnpm@latest" "${PNPM_VERSION}" \
 && pnpm --version | grep -q "^${PNPM_VERSION}$"

RUN uv python install "${PYTHON_VERSION}" && \
    ln -s "$(uv python find "${PYTHON_VERSION}")" /opt/uv/bin/python3

# pnpm blocks dependency build scripts by default and `pnpm approve-builds`
# needs a TTY, so allowlist each by name: https://github.com/pnpm/pnpm/issues/9124
#
# CXXFLAGS: gitnexus pins tree-sitter@0.21.1, whose binding.gyp hardcodes
# -std=c++17, but Node 26's V8 headers require C++20. gyp appends env
# CXXFLAGS after the target's own flags, so the later -std wins.
RUN CXXFLAGS="-std=c++20" pnpm add -g "gitnexus@${GIT_NEXUS_VERSION}" \
      --allow-build=gitnexus \
      --allow-build=@ladybugdb/core \
      --allow-build=@scarf/scarf \
      --allow-build=onnxruntime-node \
      --allow-build=protobufjs \
      --allow-build=tree-sitter \
      --allow-build=tree-sitter-c-sharp \
      --allow-build=tree-sitter-cpp \
      --allow-build=tree-sitter-go \
      --allow-build=tree-sitter-java \
      --allow-build=tree-sitter-javascript \
      --allow-build=tree-sitter-php \
      --allow-build=tree-sitter-python \
      --allow-build=tree-sitter-ruby \
      --allow-build=tree-sitter-rust \
      --allow-build=tree-sitter-typescript

# Mixin overlay: same Node base and PNPM_HOME as the anthropic, openai, and
# anomaly workloads, so gitnexus lands on their existing PATH.
FROM node:26.12-alpine3.24@sha256:40cd011b55415bc894e45b02fdd5a5dfde056921b7d23a64c74f80497af48797

LABEL authors="Jared Davis"

ARG GIT_NEXUS_VERSION=1.6.12

ENV PNPM_HOME=/opt/pnpm
ENV PATH="${PNPM_HOME}/bin:${PATH}"
# The image pins gitnexus, so its daily npm "update available" check is noise.
ENV GITNEXUS_NO_UPDATE_NOTIFIER=1

RUN apk add --no-cache bash && \
    addgroup -g 1001 sandbox && \
    adduser -D -u 1001 -G sandbox -h /home/agent -s /bin/bash agent

COPY --from=build --chown=1001:1001 /opt/pnpm /opt/pnpm

WORKDIR /home/agent

USER 1001:1001

# Runs without the build toolchain, proving the native modules load on the
# workload base alone.
RUN gitnexus --version | grep -qF "${GIT_NEXUS_VERSION}"
