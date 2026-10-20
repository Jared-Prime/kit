# syntax=docker/dockerfile:1
ARG BASE=ghcr.io/jared-prime/kit-typescript:v1.5.0

FROM scratch AS config

COPY openai.toml /etc/codex/config.toml

FROM ${BASE}

RUN pnpm add -g @openai/codex@0.162.1 --allow-build=@openai/codex && \
    test "$(codex --version)" = "codex-cli 0.162.1"

COPY --from=config /etc/codex/config.toml /etc/codex/config.toml

ENTRYPOINT [ "codex" ]
