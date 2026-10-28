# syntax=docker/dockerfile:1
FROM dhi.io/bash:5-alpine@sha256:a707212b3cedeb3241971658dba3f152d2d1a1cda5f7c4cc6f9582973b27a414 AS bash

FROM dhi.io/alpine-base:3.24-alpine3.24-dev@sha256:7182e0bc2f186386bb23bc0718508913450ba1876e93cf07e5e3cf263c4dbb63 AS extra

RUN apk add --no-cache libstdc++ && \
    addgroup -g 1001 sandbox  && \
    adduser -D -u 1001 -G sandbox -h /home/agent -s /bin/bash agent && \
    mkdir -p /home/agent/.config/opencode && \
    chown -R 1001:1001 /home/agent

FROM scratch AS config

COPY anomaly.jsonc /etc/opencode/opencode.jsonc

FROM dhi.io/node:26-alpine-dev@sha256:0614d22bcdfe1f5fbf985e68b455e61aefba8bc697894a6e91a8542a3e5f26b4 AS node

ARG PNPM_VERSION=12.15.0

ENV SHELL=/bin/bash
ENV PNPM_HOME=/opt/pnpm
ENV PATH="${PNPM_HOME}/bin:${PATH}"

RUN npx --yes "get-pnpm@latest" "${PNPM_VERSION}" \
 && pnpm --version | grep -q "^${PNPM_VERSION}$"

RUN pnpm add -g @opencode/cli@2.0.32 --allow-build=@opencode/cli && \
    test "$(opencode --version)" = "opencode v2.0.32"

FROM dhi.io/alpine-base:3.24@sha256:7b06d747fcb428a0699679955e903b13322c92c79d94ce94c108634f13a714f1

ENV SHELL=/bin/bash
ENV PNPM_HOME=/opt/pnpm
ENV PATH="${PNPM_HOME}/bin:${PATH}"

COPY --from=extra --chown=1001:1001 /home/agent /home/agent
COPY --from=extra /etc/passwd /etc/passwd
COPY --from=extra /etc/group /etc/group
COPY --from=extra /usr/lib/libstdc++.so* /usr/lib/libgcc_s.so* /usr/lib/
COPY --from=config /etc/opencode/opencode.jsonc /etc/opencode/opencode.jsonc
COPY --from=node --chown=1001:1001 /opt/pnpm /opt/pnpm
COPY --from=bash /usr/lib /usr/lib
COPY --from=bash /bin/bash /bin/bash
COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

WORKDIR /home/agent

USER 1001:1001

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
