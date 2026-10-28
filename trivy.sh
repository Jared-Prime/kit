#!/usr/bin/env bash

set -euo pipefail

mkdir -p .trivy-scan/cache && chmod -R a+rwX .trivy-scan

# Run a command silently; print its output (with the kit name) only if it fails.
quiet() {
  local out
  if ! out="$("$@" 2>&1)"; then
    printf '==> %s\n%s\n' "${kit:-setup}" "${out}" >&2
    return 1
  fi
}

quiet docker pull -q dhi.io/trivy:0-alpine

function files() {
  quiet docker run --rm -v "$(pwd)":/workspace dhi.io/trivy:0-alpine fs --format table --quiet --no-progress --exit-code 1 --severity HIGH,CRITICAL /workspace
}

function scan() {
  quiet docker build -q -f ./"$1"/"$1".dockerfile -t "$1"-kit:scan ./"$1"
  quiet docker save "$1"-kit:scan -o .trivy-scan/"$1"-kit.tar
  chmod a+r .trivy-scan/"$1"-kit.tar
  quiet docker run --rm -v "$(pwd)/.trivy-scan":/scan dhi.io/trivy:0-alpine image --format table --quiet --no-progress --exit-code 1 --input /scan/"$1"-kit.tar --cache-dir /scan/cache --severity HIGH,CRITICAL "$1"-kit:scan
}

files || exit 1

kits=("$@")
if [ "${#kits[@]}" -eq 0 ]; then
  for dir in */; do
    kit="${dir%/}"
    if [ -f "./${kit}/${kit}.dockerfile" ]; then
      kits+=("${kit}")
    fi
  done
fi

for kit in "${kits[@]}"; do
  scan "${kit}" || exit 1
done
