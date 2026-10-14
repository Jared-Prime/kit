#!/usr/bin/env bash

set -euo pipefail

echo "Context: GH_REPO = '${GH_REPO}'" >&2
echo "Context: GH_USER = '${GH_USER}'" >&2
echo "Context: GH_TEAM = '${GH_TEAM}' (comma delimited)" >&2

function list {
  gh api --method GET \
    "repos/$GH_REPO/pulls?state=open&sort=updated&direction=desc&per_page=50" |
    jq -c '[.[] | select(.draft == false)] | sort_by(.updated_at)[]'
}

function requested {
  gh api --method GET "repos/$GH_REPO/pulls/$1/requested_reviewers?per_page=100"
}

function reviews {
  gh api --method GET "repos/$GH_REPO/pulls/$1/reviews?per_page=100"
}

function details {
  gh api --method GET "repos/$GH_REPO/pulls/$1"
}

function checks {
  gh api --method GET "repos/$GH_REPO/commits/$1/check-runs?per_page=100"
}

function status {
  gh api --method GET "repos/$GH_REPO/commits/$1/status"
}

function sha {
  jq -r '.head.sha' <<<"$1"
}

function number {
  jq -r '.number' <<<"$1"
}

function shape {
  while IFS= read -r pull; do
    number=$(number "$pull")
    sha=$(sha "$pull")

    requested="$(requested "$number")"
    reviews="$(reviews "$number")"
    details="$(details "$number")"
    checks=$(checks "$sha")
    status=$(status "$sha")

    jq -cn \
      --argjson pull "$pull" \
      --argjson requested "$requested" \
      --argjson reviews "$reviews" \
      --argjson details "$details" \
      --argjson checks "$checks" \
      --argjson status "$status" '
        ($checks.check_runs // []) as $runs
        | ($status.statuses // []) as $statuses
        | {
            pr: $pull.number,
            url: $pull.html_url,
            branch: $pull.head.ref,
            title: $pull.title,
            teams: ([$requested.teams[]?.slug] | unique),
            requested_users: ([$requested.users[]?.login] | unique),
            users: ([$requested.users[]?.login, $reviews[]?.user.login] | map(select(. != null)) | unique),
            mergeable: ($details.mergeable == true),
            success: (
              ($runs | length) + ($statuses | length) > 0
              and ($checks.total_count == ($runs | length))
              and all($runs[]; .status == "completed" and .conclusion == "success")
              and (($statuses | length) == 0 or $status.state == "success")
            )
          }
      '
  done
}

list | shape
