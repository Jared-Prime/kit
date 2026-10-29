# syntax=docker/dockerfile:1
FROM ghcr.io/jared-prime/kit/claude:dev

COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --chmod=755 authorization.sh /usr/local/bin/authorization.sh

COPY managed-settings.json /etc/claude-code/managed-settings.json
COPY managed-mcp.json /etc/claude-code/managed-mcp.json

WORKDIR /home/agent

USER 1000:1000

# Owned by agent so the skills mount doesn't leave the runtime creating it as root
RUN mkdir -p /home/agent/.claude/skills

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
