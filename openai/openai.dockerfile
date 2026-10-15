# syntax=docker/dockerfile:1
FROM scratch AS configs

WORKDIR /etc/codex

COPY openai.toml /etc/codex/config.toml

FROM docker/sandbox-templates:codex@sha256:a68b972a59148c6359ade441387159033f6d196d48aef9dda06d2d4bb26eb41e

USER agent

RUN npm install -g @openai/codex@0.162.1 \
 && test "$(codex --version)" = "codex-cli 0.162.1"

COPY --from=configs /etc/codex/config.toml /etc/codex/config.toml

ENTRYPOINT [ "codex" ]
