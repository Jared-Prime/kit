# syntax=docker/dockerfile:1
ARG BASE=ghcr.io/jared-prime/kit-typescript:v1.5.0

FROM scratch AS config

COPY managed-settings.json /etc/claude-code/managed-settings.json

FROM ${BASE}

RUN pnpm add -g @anthropic-ai/claude-code@2.1.300 --allow-build=@anthropic-ai/claude-code \
 && test "$(claude --version)" = "2.1.300 (Claude Code)" \
 && mkdir -p /home/agent/.claude

COPY --from=config /etc/claude-code/managed-settings.json /etc/claude-code/managed-settings.json

ENTRYPOINT [ "claude" ]
