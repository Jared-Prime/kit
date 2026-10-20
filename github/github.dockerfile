# syntax=docker/dockerfile:1
FROM ghcr.io/j178/prek:0.5.6-alpine3.24@sha256:74bc8fa86ef51f619171f34fdaf5b67257a4796e6d469191918a0cc9846bca7c AS prek

FROM alpine:3.24@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6

RUN apk add --no-cache github-cli git jq

COPY --from=prek /usr/local/bin/prek /usr/local/bin/prek

USER 1001:1001

ENTRYPOINT ["gh"]
