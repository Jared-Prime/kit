# syntax=docker/dockerfile:1
ARG tools=ghcr.io/jared-prime/kit:latest
FROM ${tools} AS playwright

ARG CHROMIUM_REPOSITORY=https://dl-cdn.alpinelinux.org/alpine/v3.24/community

ENV SHELL=/usr/bin/bash
ENV PNPM_HOME=/opt/pnpm
ENV PATH="${PNPM_HOME}/bin:${PATH}"
ENV PLAYWRIGHT_MCP_EXECUTABLE_PATH=/usr/bin/chromium
ENV PLAYWRIGHT_MCP_SANDBOX=false
ENV PLAYWRIGHT_MCP_HEADLESS=true
ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1

RUN find / -xdev \( -type f -o -type l \) | sort > /tmp/before

RUN apk add --no-cache --repository ${CHROMIUM_REPOSITORY} chromium nss-tools && \
    test -x "${PLAYWRIGHT_MCP_EXECUTABLE_PATH}" && \
    test -x /usr/bin/certutil

RUN pnpm add -g "@playwright/cli@0.1.23" \
 && playwright-cli --version | grep -q "^0.1.23$"

RUN find / -xdev \( -type f -o -type l \) | sort > /tmp/after && \
    comm -13 /tmp/before /tmp/after \
      | grep -v -e '^/tmp/' -e '^/rootfs/' -e '^/lib/apk/' -e '^/etc/apk/' \
                -e '^/var/cache/' -e '^/root/' -e '^/home/' > /tmp/new && \
    wc -l /tmp/new && \
    mkdir /rootfs && \
    tar -cf - -T /tmp/new | tar -xf - -C /rootfs && \
    test -e /rootfs/usr/lib/chromium/chromium && \
    test -e /rootfs/usr/lib/chromium/chromium-launcher.sh

WORKDIR /home/agent

RUN playwright-cli install --skills

FROM scratch

ENV PLAYWRIGHT_MCP_EXECUTABLE_PATH=/usr/bin/chromium
ENV PLAYWRIGHT_MCP_SANDBOX=false
ENV PLAYWRIGHT_MCP_HEADLESS=true
ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1

COPY --from=playwright /rootfs/ /
COPY --from=playwright /home/agent/.claude/skills/playwright-cli /usr/share/kit/skills/playwright-cli
COPY --chmod=755 chromium-ca.sh /usr/share/kit/entrypoint.d/10-chromium-ca.sh

USER 1000:1000
