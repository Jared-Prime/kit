#!/usr/bin/env bash

set -euo pipefail

echo "Context: GH_REPO = '${GH_REPO}'" >&2
echo "Context: GH_USER = '${GH_USER}'" >&2
echo "Context: GH_TEAM = '${GH_TEAM}' (comma delimited)" >&2
echo "Context: CLONE_URL = '${CLONE_URL}'" >&2
echo "Context: PR_NUMBER = '${PR_NUMBER}'" >&2

checkout_dir="${HOME}/review/${PR_NUMBER}"

if [[ -e "$checkout_dir" || -L "$checkout_dir" ]]; then
  printf 'Checkout already exists: %s\n' "$checkout_dir" >&2
  exit 1
fi

base_branch=$(gh api --method GET "repos/$GH_REPO/pulls/$PR_NUMBER" | jq -r '.base.ref // empty')
if [[ -z "$base_branch" ]]; then
  printf 'Could not determine base branch for PR %s\n' "$PR_NUMBER" >&2
  exit 1
fi

mkdir -p "${HOME}/review"

function clone {
  git clone --single-branch -b "$base_branch" "$CLONE_URL" "$checkout_dir"
}

function branch {
  git fetch origin "refs/pull/$1/head:refs/remotes/origin/pr/$1"
  git switch -c "review/$1" "origin/pr/$1"
  git merge-base "$base_branch" HEAD >/dev/null
}

clone
(cd "$checkout_dir"; branch "$PR_NUMBER")

echo "${PR_NUMBER} is now reviewable in ${checkout_dir}"
