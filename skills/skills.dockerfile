FROM alpine:3.22@sha256:5291449c3df73caf6ed85e649dec1b9e818b39a5d8c871e97afc13e9cd5e8fa8 AS contents

WORKDIR /home/agent

COPY guided-review .agents/skills/guided-review
RUN ln -s .agents .claude

FROM scratch

COPY --from=contents /home/agent /home/agent
