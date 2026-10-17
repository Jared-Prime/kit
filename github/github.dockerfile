# syntax=docker/dockerfile:1
FROM ubuntu:26.04@sha256:c098726dd9b9733f3e885f8de0ef375206a311b0a317eadc40d347b1115fb944 AS build

ARG GH_VERSION=2.102.0

RUN (type -p wget >/dev/null || (apt update && apt install wget -y)) \
	&& mkdir -p -m 755 /etc/apt/keyrings \
	&& out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
	&& cat $out | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& mkdir -p -m 755 /etc/apt/sources.list.d \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& apt update \
    && apt install -y "gh=${GH_VERSION}" \
    && gh --version | grep -q "^gh version ${GH_VERSION} " \
    && rm -rf /var/lib/apt/lists/*

FROM scratch

COPY --from=build /usr/bin/gh /usr/local/bin/gh

ENTRYPOINT ["/usr/local/bin/gh"]
CMD ["--help"]
