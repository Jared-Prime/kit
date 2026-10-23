# syntax=docker/dockerfile:1
FROM docker.aikido.io/28575c9157ce15768c408/alpine:3.24@sha256:bce62d40979e1a675e7cfee140cb4d58111573446bdb2f84fe8a76f21ccfaa86 AS codebase

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
    tar -xzf /tmp/cbm.tar.gz -C /tmp/cbm codebase-memory-mcp LICENSE THIRD_PARTY_NOTICES.md

FROM scratch

LABEL authors="Jared Davis"

COPY --from=codebase --chmod=0755 /tmp/cbm/codebase-memory-mcp /usr/local/bin/codebase-memory-mcp
COPY --from=codebase /tmp/cbm/LICENSE /tmp/cbm/THIRD_PARTY_NOTICES.md /usr/local/share/doc/codebase-memory-mcp/

USER 1001:1001

ENTRYPOINT [ "codebase-memory-mcp" ]
