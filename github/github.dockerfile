# syntax=docker/dockerfile:1
FROM nixos/nix:2.35.3 AS build

WORKDIR /src

COPY flake.nix flake.nix

RUN nix --extra-experimental-features 'nix-command flakes' build .

RUN mkdir -p /out/nix/store /out/usr/local/bin && \
    cp -a $(nix-store --query --requisites result) /out/nix/store/ && \
    ln -s "$(readlink -f result)/bin/gh" /out/usr/local/bin/gh

FROM scratch
COPY --from=build /out /

ENTRYPOINT ["gh"]
CMD ["--help"]
