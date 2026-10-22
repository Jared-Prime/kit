# syntax=docker/dockerfile:1
FROM ghcr.io/astral-sh/uv:0.13.5-alpine@sha256:6ba9c830aa848d21e1e9d8028ae01ed02b08980b25aeabef9a6683c5743c6d0f AS uv

LABEL authors="Jared Davis"

ARG PYTHON_VERSION=3.14

ENV UV_PYTHON_INSTALL_DIR=/opt/uv/python
ENV PATH="/opt/uv/bin:${PATH}"

RUN apk add --no-cache bash && \
    addgroup -g 1001 sandbox && \
    adduser -D -u 1001 -G sandbox -h /home/agent -s /bin/bash agent && \
    mkdir -p "${UV_PYTHON_INSTALL_DIR}" /opt/uv/bin && \
    cp "$(command -v uv)" "$(command -v uvx)" /opt/uv/bin/ && \
    chown -R 1001:1001 /opt/uv

WORKDIR /home/agent

USER 1001:1001

RUN uv python install "${PYTHON_VERSION}" && \
    uv python list --only-installed | grep -q "cpython-${PYTHON_VERSION}"

# isolate uv as the default package manager
RUN pybin="$(uv python find "${PYTHON_VERSION}")" && \
    uv pip uninstall --python "${pybin}" --break-system-packages pip && \
    ! "${pybin}" -m pip --version
