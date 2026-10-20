#!/bin/sh
# Feeds the sandbox-generated agent context (built from each composed kit's
# agent-context@1 capability) into opencode via its global AGENTS.md, the
# only hook opencode exposes for persistent instructions (it has no
# --append-system-prompt equivalent). Falls back to a bare launch when no
# kits declare agent-context@1.
set -e

# Trusts the egress proxy's MITM CA so TLS clients (npm, MCP connections,
# curl, etc.) don't fail with SELF_SIGNED_CERT_IN_CHAIN. The proxy injects
# its CA cert as a base64 env var; the build stage chowns the cert store so
# this non-root user can update it.
if [ -n "$PROXY_CA_CERT_B64" ]; then
  echo "$PROXY_CA_CERT_B64" | base64 -d > /usr/local/share/ca-certificates/proxy-ca.crt
  update-ca-certificates
fi

context_file="/usr/share/sandbox/kit/opencode.generated/context.md"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"

if [ -f "$context_file" ]; then
  mkdir -p "$config_dir"
  cp "$context_file" "$config_dir/AGENTS.md"
fi

exec opencode "$@"
