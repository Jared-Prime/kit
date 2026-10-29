# syntax=docker/dockerfile:1
FROM ghcr.io/jared-prime/kit/claude:dev

COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

COPY managed-settings.json /etc/claude-code/managed-settings.json
COPY managed-mcp.json /etc/claude-code/managed-mcp.json

WORKDIR /home/agent

USER 1000:1000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
