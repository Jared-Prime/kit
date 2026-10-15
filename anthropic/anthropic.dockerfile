# syntax=docker/dockerfile:1
FROM scratch AS configs

WORKDIR /etc/claude-code

COPY managed-settings.json /etc/claude-code/managed-settings.json

FROM docker/sandbox-templates:claude-code@sha256:868e3f5ef10579e06903d42e86448851ed59319ab8b9fba6dea2772c449bb2a6

USER agent

RUN claude install 2.1.300 \
 && test "$(claude --version)" = "2.1.300 (Claude Code)"

COPY --from=configs /etc/claude-code/managed-settings.json /etc/claude-code/managed-settings.json

ENTRYPOINT [ "claude" ]
