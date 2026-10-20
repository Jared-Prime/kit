#!/bin/sh
# Feeds the sandbox-generated agent context (built from each composed kit's
# agent-context@1 capability) into Claude Code as an appended system prompt.
# Falls back to a bare launch when no kits declare agent-context@1.
set -e

# Trusts the egress proxy's MITM CA so TLS clients (npm, MCP connections,
# curl, etc.) don't fail with SELF_SIGNED_CERT_IN_CHAIN. The proxy injects
# its CA cert as a base64 env var; the build stage chowns the cert store so
# this non-root user can update it.
if [ -n "$PROXY_CA_CERT_B64" ]; then
  echo "$PROXY_CA_CERT_B64" | base64 -d > /usr/local/share/ca-certificates/proxy-ca.crt
  update-ca-certificates
fi

context_file="/usr/share/sandbox/kit/claude.generated/context.md"

if [ -f "$context_file" ]; then
  exec claude --append-system-prompt-file "$context_file" "$@"
else
  exec claude "$@"
fi
