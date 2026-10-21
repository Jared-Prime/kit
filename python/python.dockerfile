# syntax=docker/dockerfile:1
FROM ghcr.io/astral-sh/uv:0.13.4-alpine@sha256:325c1a47db636422f3d1e6a935a0a9d0e6395031665e5baa033d1691ddc9c27e AS uv

LABEL authors="Jared Davis"

ARG PYTHON_VERSION=3.14
ARG PIP_VERSION=26.2.2
ARG CERTIFI_VERSION=2026.10.19

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

# pip vendors its own certifi, ignoring REQUESTS_CA_BUNDLE/SSL_CERT_FILE (GHSA-hq85-5cpj-mr62, Oct 2026).
RUN pybin="$(uv python find "${PYTHON_VERSION}")" && \
    uv pip install --python "${pybin}" --break-system-packages --no-cache "pip==${PIP_VERSION}" "certifi==${CERTIFI_VERSION}" && \
    "${pybin}" -m pip --version | grep -q "^pip ${PIP_VERSION} " && \
    "${pybin}" -m pip show certifi | grep -q "^Version: ${CERTIFI_VERSION}$"
