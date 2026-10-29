#!/usr/bin/env bash

set -euo pipefail

function prune {
  rm -f "$(pwd)/*.tar"
  docker system prune -f
}

function unpack {
  rm -rf "$2" && mkdir -p "$2"
  tar -xf "$1" -C "$2"
}

function inspect {
  tar -xOf "$1" index.json | jq '.manifests[] | { name: .annotations["io.containerd.image.name"], digest, platform }'
}

function latest {
  docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --quiet \
    --output "type=oci,dest=$(pwd)/latest.kit.tar" \
    -t ghcr.io/jared-prime/kit:dev \
    -f "$(pwd)/Dockerfile" "$(pwd)"
  inspect "$(pwd)/latest.kit.tar"
}

function scan {
  local ref="ghcr.io/jared-prime/kit/$1:dev"
  [ "$1" = "latest" ] && ref="ghcr.io/jared-prime/kit:dev"
  docker load -i "$(pwd)/$1.kit.tar"
  docker save --platform "$2" "${ref}" -o "$(pwd)/.cache/trivy-$1.tar"
  chmod a+r "$(pwd)/.cache/trivy-$1.tar"
  docker run \
    --rm \
    -v "$(pwd)/.cache/trivy-$1.tar":/scan/image.tar:ro \
    -v "$(pwd)/.trivyignore":/scan/.trivyignore:ro \
    -v "$(pwd)/.cache/trivy":/scan/cache \
    dhi.io/trivy:0-alpine image \
    --format table \
    --quiet \
    --no-progress \
    --exit-code 1 \
    --input /scan/image.tar \
    --cache-dir /scan/cache \
    --ignorefile /scan/.trivyignore \
    --severity HIGH,CRITICAL \
    --platform "$2"
}

function kit {
  docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --quiet \
    --target "$1" \
    --output "type=oci,dest=$(pwd)/$1.kit.tar" \
    -t "ghcr.io/jared-prime/kit/$1:dev" \
    -f "$(pwd)/Dockerfile" "$(pwd)"
  inspect "$(pwd)/$1.kit.tar"
}

function workload {
  unpack "$(pwd)/$2.kit.tar" "$(pwd)/.cache/layout/$2"
  docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --quiet \
    --build-context "ghcr.io/jared-prime/kit/$2:dev=oci-layout://$(pwd)/.cache/layout/$2" \
    --output "type=oci,dest=$(pwd)/$1.workload.tar" \
    -t "ghcr.io/jared-prime/workload/$1:dev" \
    -f "./$1/$1.dockerfile" "./$1"
  inspect "$(pwd)/$1.workload.tar"
}

function sandbox {
  docker load -i "$(pwd)/$2.kit.tar"
  docker buildx build \
    --quiet \
    --platform linux/amd64,linux/arm64 \
    --file "./$1/$1.yaml" \
    --output "type=oci,dest=$(pwd)/$1.sandbox.tar" \
    --tag "ghcr.io/jared-prime/sandbox/$1:dev" \
    "$(pwd)/$1"
  inspect "$(pwd)/$1.sandbox.tar"
}

prune

latest

kit "claude"
kit "codex"
kit "opencode"

for plaform in linux/amd64 linux/arm64; do
  scan "latest"   "$plaform"
  scan "claude"   "$plaform"
  scan "codex"    "$plaform"
  scan "opencode" "$plaform"
done

workload "anomaly"   "opencode"
workload "anthropic" "claude"
workload "openai"    "codex"

sandbox  "anomaly"   "opencode"
sandbox  "anthropic" "claude"
sandbox  "openai"    "codex"
