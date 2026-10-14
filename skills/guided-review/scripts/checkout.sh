#!/usr/bin/env bash

set -euo pipefail

echo "Context: GH_REPO = '${GH_REPO}'" >&2
echo "Context: GH_USER = '${GH_USER}'" >&2
echo "Context: GH_TEAM = '${GH_TEAM}' (comma delimited)" >&2
echo "Context: SSH_URL = '${SSH_URL}'" >&2
echo "Context: GH_HEAD = '${GH_HEAD}'" >&2

checkout_dir="${HOME}/review/${GH_HEAD}"

mkdir -p "$checkout_dir"

function clone {
  git clone --depth 1 --single-branch -b main "$SSH_URL" "$checkout_dir"
}

function switch {
  git fetch --depth 1 origin "${GH_HEAD}:refs/remotes/origin/${GH_HEAD}"
  git switch -c "$GH_HEAD" "origin/$GH_HEAD"
}

clone
(cd "$checkout_dir"; switch)

echo "${GH_HEAD} is now reviewable in ${checkout_dir}"
