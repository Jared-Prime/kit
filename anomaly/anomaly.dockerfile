FROM scratch AS config

COPY anomaly.jsonc /etc/opencode/opencode.jsonc

FROM ghcr.io/anomalyco/opencode:2.0.32

RUN apk add --no-cache bash git \
    && addgroup -g 1000 agent \
    && adduser -D -u 1000 -G agent -h /home/agent -s /bin/bash agent

USER agent

COPY --from=config /etc/opencode /etc/opencode

ENTRYPOINT ["opencode"]
