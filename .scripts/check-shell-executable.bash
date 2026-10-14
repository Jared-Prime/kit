#!/usr/bin/env bash

set -euo pipefail

failed=0
for file in "$@"; do
  index_entry=$(git ls-files --stage -- "$file")
  mode=${index_entry%% *}
  if [[ $mode != 100755 ]]; then
    printf '%s must be staged as executable (mode 100755); run chmod +x and git add.\n' "$file" >&2
    failed=1
  fi
done

exit "$failed"
