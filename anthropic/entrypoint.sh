#!/bin/sh
# Feeds the sandbox-generated agent context (built from each composed kit's
# agent-context@1 capability) into Claude Code as an appended system prompt.
# Falls back to a bare launch when no kits declare agent-context@1.
set -e

context_file="/usr/share/sandbox/kit/claude.generated/context.md"

if [ -f "$context_file" ]; then
  exec claude --append-system-prompt-file "$context_file" "$@"
else
  exec claude "$@"
fi
