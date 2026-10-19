# syntax=docker/dockerfile:1
ARG BASE=ghcr.io/jared-prime/kit-typescript:v1.4.2

FROM scratch AS config

COPY anomaly.jsonc /etc/opencode/opencode.jsonc

FROM ${BASE}

RUN pnpm add -g @opencode/cli@2.0.32 --allow-build=@opencode/cli && \
    test "$(opencode --version)" = "opencode v2.0.32"

COPY --from=config /etc/opencode/opencode.jsonc /etc/opencode/opencode.jsonc

ENTRYPOINT ["opencode"]
