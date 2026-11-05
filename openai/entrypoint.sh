#!/bin/sh
# Feeds the sandbox-generated agent context (built from each composed kit's
# agent-context@1 capability) into Codex via its global AGENTS.md, the only
# hook Codex exposes for persistent instructions (it has no
# --append-system-prompt equivalent). Falls back to a bare launch when no
# kits declare agent-context@1.
set -e

# Trusts the egress proxy's MITM CA so TLS clients (npm, MCP connections,
# curl, etc.) don't fail with SELF_SIGNED_CERT_IN_CHAIN. The proxy injects
# its CA cert as a base64 env var. The sandbox only grants this user write
# access under $HOME, so rather than updating the system trust store, build
# a combined bundle there and point TLS clients at it via env vars.
if [ -n "$PROXY_CA_CERT_B64" ]; then
  ca_dir="$HOME/.local/share/ca-certificates"
  mkdir -p "$ca_dir"
  echo "$PROXY_CA_CERT_B64" | base64 -d > "$ca_dir/proxy-ca.crt"
  cat /etc/ssl/certs/ca-certificates.crt "$ca_dir/proxy-ca.crt" > "$ca_dir/ca-bundle.crt"
  export SSL_CERT_FILE="$ca_dir/ca-bundle.crt"
  export NODE_EXTRA_CA_CERTS="$ca_dir/ca-bundle.crt"
  export REQUESTS_CA_BUNDLE="$ca_dir/ca-bundle.crt"
  export CURL_CA_BUNDLE="$ca_dir/ca-bundle.crt"
fi

context_file="/usr/share/sandbox/kit/codex.generated/context.md"
codex_home="${CODEX_HOME:-$HOME/.codex}"

if [ -f "$context_file" ]; then
  mkdir -p "$codex_home"
  cp "$context_file" "$codex_home/AGENTS.md"
fi

exec codex "$@"
