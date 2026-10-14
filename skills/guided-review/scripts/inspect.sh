#!/usr/bin/env bash

set -euo pipefail

: "${GH_REPO:?Set GH_REPO=OWNER/REPO}"
PR_NUMBER="${1:?Usage: inspect.sh PR_NUMBER}"

echo "Gathering Pull Request $PR_NUMBER information from $GH_REPO" >&2

function commits {
  gh api "repos/$GH_REPO/pulls/$PR_NUMBER/commits" |
  jq -c '
    .[]
    | {
      kind: "commits",
      sha,
      message: .commit.message
    }
  '
}

function reviews {
  gh api "repos/$GH_REPO/pulls/$PR_NUMBER/reviews" |
  jq -c '
    .[]
    | {
      kind: "reviews",
      author: .user.login,
      id,
      state,
      body,
      commit_id,
      submitted_at
    }
  '
}

function comments {
  gh api "repos/$GH_REPO/pulls/$PR_NUMBER/comments" |
  jq -c '
    .[]
    | {
      kind: "comments",
      author: .user.login,
      id,
      body,
      path,
      line,
      original_line,
      side,
      in_reply_to_id,
      commit_id,
      original_commit_id
    }
  '
}

function issues {
  gh api "repos/$GH_REPO/issues/$PR_NUMBER/comments" |
  jq -c '
    .[]
    | {
      kind: "issues",
      author: .user.login,
      id,
      body
    }
  '
}

function changes {
  gh api "repos/$GH_REPO/pulls/$PR_NUMBER/files" |
  jq -c '
    .[]
    | {
      kind: "changes",
      filename,
      previous_filename,
      status,
      additions,
      deletions,
      changes
    }
  '
}

function runs {
  gh api "repos/$GH_REPO/commits/$1/check-runs" |
  jq -c '
    .check_runs[]
    | {
      kind: "runs",
      name,
      status,
      conclusion,
      head_sha
    }
  '
}

function status {
  gh api "repos/$GH_REPO/commits/$1/status" |
  jq -c '
    {
      kind: "status",
      state,
      statuses: [
        .statuses[] | {
          context, state, description
        }
      ]
    }
  '
}

function pulls {
  jq -c '{
    kind: "pulls",
    number,
    title,
    body,
    state,
    draft,
    base: { ref: .base.ref, sha: .base.sha },
    head: { ref: .head.ref, sha: .head.sha },
    changed_files,
    commits,
    additions,
    deletions
  }'<<<"$1"
}

data="$(gh api "repos/$GH_REPO/pulls/$PR_NUMBER")"

sha="$(jq -r '.head.sha' <<<"$data")"

pulls "$data"
status "$sha"
runs "$sha"
commits
reviews
comments
issues
changes
