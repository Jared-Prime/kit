#!/usr/bin/env bash

set -euo pipefail

scriptdir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

echo "Context: GH_REPO = '${GH_REPO}'" >&2
echo "Context: GH_USER = '${GH_USER}'" >&2
echo "Context: GH_TEAM = '${GH_TEAM}' (comma delimited)" >&2

function request {
    . "$scriptdir/request.sh"
}

function available {
  jq -sr --arg team "$GH_TEAM" --arg user "$GH_USER" '
    def checkbox: "- [ ] [PR\(.pr)](\(.url)): \(.title) - `\(.branch)`";

    def available:
      ( $team | split(",")) as $t
      | [.teams[] | select(IN($t[]))]
      | length > 0;

    .[]
    | select(available)
    | select(.success)
    | checkbox
  '
}

request | available
