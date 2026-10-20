#!/bin/sh
# Feeds the sandbox-generated agent context (built from each composed kit's
# agent-context@1 capability) into opencode via its global AGENTS.md, the
# only hook opencode exposes for persistent instructions (it has no
# --append-system-prompt equivalent). Falls back to a bare launch when no
# kits declare agent-context@1.
set -e

context_file="/usr/share/sandbox/kit/opencode.generated/context.md"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"

if [ -f "$context_file" ]; then
  mkdir -p "$config_dir"
  cp "$context_file" "$config_dir/AGENTS.md"
fi

exec opencode "$@"
