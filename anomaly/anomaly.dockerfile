# syntax=docker/dockerfile:1
ARG tools=ghcr.io/jared-prime/kit:latest
FROM ${tools}

ENV SHELL=/usr/bin/bash
ENV PNPM_HOME=/opt/pnpm
ENV PATH="${PNPM_HOME}/bin:${PATH}"

RUN pnpm add -g @opencode/cli@2.3.0 --allow-build=@opencode/cli && \
    test "$(opencode --version)" = "opencode v2.3.0"

COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

COPY anomaly.jsonc /etc/opencode/opencode.jsonc

WORKDIR /home/agent

USER 1000:1000

# Owned by agent so the skills mount doesn't leave the runtime creating it as root
RUN mkdir -p /home/agent/.config/opencode

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
