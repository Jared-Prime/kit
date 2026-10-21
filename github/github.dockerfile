# syntax=docker/dockerfile:1
FROM ghcr.io/j178/prek:0.5.7-alpine3.24@sha256:15402f864b885e927891cd320eb711cf125d424c8a45f6837a55618fdfbe93a3 AS prek

FROM alpine:3.24@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6

RUN apk add --no-cache github-cli git jq

COPY --from=prek /usr/local/bin/prek /usr/local/bin/prek

USER 1001:1001

ENTRYPOINT ["gh"]
