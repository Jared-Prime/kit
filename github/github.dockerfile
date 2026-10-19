# syntax=docker/dockerfile:1
FROM node:24.22-alpine3.24@sha256:44fce696f38ba8c987c4db89954051000bbd05ffd8d8659ba15ed4a8602e937f

RUN apk add --no-cache github-cli

USER 1001:1001

ENTRYPOINT ["gh"]
