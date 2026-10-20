# syntax=docker/dockerfile:1
FROM ghcr.io/astral-sh/uv:0.13.4-alpine AS build

ARG PYTHON_VERSION=3.14

ENV UV_PYTHON_INSTALL_DIR=/opt/uv/python

RUN uv --version | grep -q "uv 0.13.3" && \
    uv python install "${PYTHON_VERSION}" && \
    uv python list --only-installed | grep -q "cpython-${PYTHON_VERSION}"

FROM scratch

LABEL authors="Jared Davis"

COPY --from=build /usr/local/bin/uv /usr/local/bin/uvx /bin/
COPY --from=build --chown=1001:1001 /opt/uv/python /opt/uv/python

ENV UV_PYTHON_INSTALL_DIR=/opt/uv/python
