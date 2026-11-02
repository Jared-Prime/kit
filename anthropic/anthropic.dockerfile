# syntax=docker/dockerfile:1
ARG tools=ghcr.io/jared-prime/kit:dev
FROM ${tools}

ENV SHELL=/usr/bin/bash
ENV PNPM_HOME=/opt/pnpm
ENV PATH="${PNPM_HOME}/bin:${PATH}"

RUN pnpm add -g @anthropic-ai/claude-code@2.1.312 --allow-build=@anthropic-ai/claude-code && \
    test "$(claude --version)" = "2.1.312 (Claude Code)"

COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --chmod=755 authorization.sh /usr/local/bin/authorization.sh

COPY managed-settings.json /etc/claude-code/managed-settings.json
COPY managed-mcp.json /etc/claude-code/managed-mcp.json

WORKDIR /home/agent

USER 1000:1000

# Owned by agent so the skills mount doesn't leave the runtime creating it as root
RUN mkdir -p /home/agent/.claude/skills

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
