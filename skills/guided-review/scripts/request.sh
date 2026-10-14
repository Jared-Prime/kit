#!/usr/bin/env bash

set -euo pipefail

echo "Context: GH_REPO = '${GH_REPO}'" >&2
echo "Context: GH_USER = '${GH_USER}'" >&2
echo "Context: GH_TEAM = '${GH_TEAM}' (comma delimited)" >&2

function list {
  gh pr list \
  --repo "$GH_REPO" \
  --draft=false     \
  --limit=50        \
  --json url,title,reviews,reviewDecision,reviewRequests,mergeable,statusCheckRollup,headRefName,updatedAt,number
}

function shape {
  jq -r '
    def success:
      if .__typename == "StatusContext" then .state == "SUCCESS"
      elif .__typename == "CheckRun" then .status == "COMPLETED" and (.conclusion == "SUCCESS")
      else false end;

    def teams:
      [ .reviewRequests[]? | select(.__typename == "Team") | .slug ]
      | unique;

    def users:
      ([ .reviewRequests[]? | select(.__typename == "User") | .login ]
       + [ .reviews[]? | .author.login? | select(. != null)])
      | unique;

    sort_by(.updatedAt)
    | .[]
    | (.mergeable == "MERGEABLE") as $mergeable
    | [.statusCheckRollup[]?] as $checks
    | (($checks | length) > 0 and all($checks[]; success)) as $success
    | (.reviewDecision == "APPROVED") as $approved
    | {
      pr: .number,
      url,
      branch: .headRefName,
      title,
      teams: (teams),
      users: (users),
      mergeable: $mergeable,
      success: $success
    }
  '
}

list | shape
