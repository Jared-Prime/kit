# syntax=docker/dockerfile:1
FROM scratch

COPY introspection /usr/share/kit/skills/introspection
COPY codebase-memory /usr/share/kit/skills/codebase-memory
COPY guided-review /usr/share/kit/skills/guided-review
COPY commit-message /usr/share/kit/skills/commit-message
