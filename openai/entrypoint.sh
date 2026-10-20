#!/bin/sh
# Feeds the sandbox-generated agent context (built from each composed kit's
# agent-context@1 capability) into Codex via its global AGENTS.md, the only
# hook Codex exposes for persistent instructions (it has no
# --append-system-prompt equivalent). Falls back to a bare launch when no
# kits declare agent-context@1.
set -e

context_file="/usr/share/sandbox/kit/codex.generated/context.md"
codex_home="${CODEX_HOME:-$HOME/.codex}"

if [ -f "$context_file" ]; then
  mkdir -p "$codex_home"
  cp "$context_file" "$codex_home/AGENTS.md"
fi

exec codex "$@"
