#!/usr/bin/env bash

set -e

function oauth {
  cat > /home/agent/.codex/config.toml << TOML
forced_login_method = "api"
model_provider = "sandboxd"

[model_providers.sandboxd]
name = "Sandbox Proxy"
base_url = "https://chatgpt.com/backend-api/codex"
experimental_bearer_token = "oai-oat01-proxy-managed"
requires_openai_auth = false
TOML

  cat > /home/agent/.codex/auth.json << JSON
{
    "OPENAI_API_KEY": "proxy-managed"
}
JSON
}

function apikey {
  cat > /home/agent/.codex/config.toml << TOML
forced_login_method = "api"
TOML

  cat > /home/agent/.codex/auth.json << JSON
{
    "OPENAI_API_KEY": "proxy-managed"
}
JSON
}

function chatgpt {
  cat > /home/agent/.codex/config.toml << TOML
forced_login_method = "chatgpt"
TOML
}

mkdir -p /home/agent/.codex

case "${SBX_CRED_OPENAI_MODE:-none}" in
  oauth)
    oauth
    ;;
  apikey)
    apikey
    ;;
  none)
    chatgpt
    ;;
  *)
    echo "unknown SBX_CRED_OPENAI_MODE: ${SBX_CRED_OPENAI_MODE}" >&2
    exit 1
esac
