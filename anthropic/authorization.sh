#!/usr/bin/env bash

set -e

function proxy {
  cat > /home/agent/.claude/settings.json << JSON
{
  "apiKeyHelper": "echo proxy-managed"
}
JSON
}

mkdir -p /home/agent/.claude

case "${SBX_CRED_ANTHROPIC_MODE:-none}" in
  oauth | apikey)
    proxy
    ;;
  none)
    # Claude Code prompts for /login
    ;;
  *)
    echo "unknown SBX_CRED_ANTHROPIC_MODE: ${SBX_CRED_ANTHROPIC_MODE}" >&2
    exit 1
esac
