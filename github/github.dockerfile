# syntax=docker/dockerfile:1
FROM ghcr.io/j178/prek:0.5.7-alpine3.24@sha256:15402f864b885e927891cd320eb711cf125d424c8a45f6837a55618fdfbe93a3 AS prek

FROM docker.aikido.io/28575c9157ce15768c408/alpine:3.24@sha256:bce62d40979e1a675e7cfee140cb4d58111573446bdb2f84fe8a76f21ccfaa86
RUN apk add --no-cache github-cli git jq

COPY --from=prek /usr/local/bin/prek /usr/local/bin/prek

USER 1001:1001

ENTRYPOINT ["gh"]
