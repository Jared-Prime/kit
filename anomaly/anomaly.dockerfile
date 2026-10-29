# syntax=docker/dockerfile:1
FROM ghcr.io/jared-prime/kit/opencode:dev

COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

COPY anomaly.jsonc /etc/opencode/opencode.jsonc

WORKDIR /home/agent

USER 1000:1000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
