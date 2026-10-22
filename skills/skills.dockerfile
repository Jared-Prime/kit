# syntax=docker/dockerfile:1
FROM scratch

COPY guided-review /usr/share/kit/skills/guided-review
COPY commit-message /usr/share/kit/skills/commit-message
COPY introspection /usr/share/kit/skills/introspection

USER 1001:1001
