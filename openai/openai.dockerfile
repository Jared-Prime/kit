# syntax=docker/dockerfile:1
ARG tools=ghcr.io/jared-prime/kit:latest
FROM ${tools}

ENV SHELL=/usr/bin/bash
ENV PNPM_HOME=/opt/pnpm
ENV PATH="${PNPM_HOME}/bin:${PATH}"

RUN pnpm add -g @openai/codex@0.166.0 --allow-build=@openai/codex && \
    test "$(codex --version)" = "codex-cli 0.166.0"

# Codex bundles an rg build requiring a glibc loader
# Remove it so the Alpine ripgrep package (copied into the final stage) is used
RUN rg="$(find "${PNPM_HOME}" -path '*/codex-path/rg' -type f -print -quit)" && \
    test -n "${rg}" && \
    rm "${rg}"

COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --chmod=755 authorization.sh /usr/local/bin/authorization.sh

COPY openai.toml /etc/codex/config.toml
COPY rules /etc/codex/rules

WORKDIR /home/agent

USER 1000:1000

# Owned by agent so the skills mount doesn't leave the runtime creating it as root
RUN mkdir -p /home/agent/.agents/skills /home/agent/.codex /home/agent/.cache

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
