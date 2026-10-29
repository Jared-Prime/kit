# syntax=docker/dockerfile:1
FROM ghcr.io/jared-prime/kit/opencode:dev

COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

COPY anomaly.jsonc /etc/opencode/opencode.jsonc

WORKDIR /home/agent

USER 1000:1000

# Owned by agent so the skills mount doesn't leave the runtime creating it as root
RUN mkdir -p /home/agent/.config/opencode

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
