# syntax=docker/dockerfile:1
FROM ghcr.io/jared-prime/kit/codex:dev

COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --chmod=755 authorization.sh /usr/local/bin/authorization.sh

COPY openai.toml /etc/codex/config.toml
COPY rules /etc/codex/rules

WORKDIR /home/agent

USER 1000:1000

# Owned by agent so the skills mount doesn't leave the runtime creating it as root
RUN mkdir -p /home/agent/.agents/skills /home/agent/.codex /home/agent/.cache

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
