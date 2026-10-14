#!/usr/bin/env bash

set -euo pipefail

echo "Gathering context for $GH_REPO" >&2

function user {
  gh api user --jq .login
}

function source {
  gh api "repos/$GH_REPO" --jq .ssh_url
}

function team {
  local org=${GH_REPO%%/*}
  gh api user/teams --paginate |
    jq -sr --arg org "$org" '
      [
        .[][]
        | select(.organization.login == $org)
        | .slug
      ] | join(",")
    '
}

echo "GH_REPO = '${GH_REPO}'"
echo "GH_USER = '$(user)'"
echo "GH_TEAM = '$(team)' (comma delimited)"
echo "SSH_URL = '$(source)'"
