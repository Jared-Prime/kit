# syntax=docker/dockerfile:1
FROM ghcr.io/jared-prime/kit/codex:dev

COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

COPY openai.toml /etc/codex/config.toml
COPY rules /etc/codex/rules

WORKDIR /home/agent

USER 1000:1000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
