#!/usr/bin/env python3
"""Serve REST-shaped GitHub fixtures to the guided-review tests."""

import json
import os
import sys


args = sys.argv[1:]
if len(args) != 4 or args[:3] != ["api", "--method", "GET"]:
    sys.exit(f"expected an explicit REST GET call, got: {args}")

endpoint = args[3]
path, _, query = endpoint.partition("?")
parts = path.split("/")
prs = json.loads(os.environ["MOCK_PRS"])

if parts == ["repos", "example", "repo", "pulls"]:
    if "per_page=50" not in query:
        sys.exit(f"expected a 50-PR limit, got: {endpoint}")
    result = [
        {key: pull[key] for key in ("number", "draft", "html_url", "head", "title", "updated_at")}
        for pull in prs
    ]
elif parts[:4] == ["repos", "example", "repo", "pulls"] and len(parts) >= 5:
    pull = next(pr for pr in prs if str(pr["number"]) == parts[4])
    if len(parts) == 5:
        result = {"mergeable": pull["mergeable"], "base": pull["base"]}
    elif parts[5] == "requested_reviewers":
        result = {"users": pull["requested_reviewers"], "teams": pull["requested_teams"]}
    elif parts[5] == "reviews":
        result = pull["reviews"]
    else:
        sys.exit(f"unexpected endpoint: {endpoint}")
elif parts[:4] == ["repos", "example", "repo", "commits"] and len(parts) == 6:
    pull = next(pr for pr in prs if pr["head"]["sha"] == parts[4])
    if parts[5] == "check-runs":
        result = {"total_count": len(pull["check_runs"]), "check_runs": pull["check_runs"]}
    elif parts[5] == "status":
        statuses = pull["statuses"]
        result = {
            "state": "success" if all(item["state"] == "success" for item in statuses) else "failure",
            "statuses": statuses,
        }
    else:
        sys.exit(f"unexpected endpoint: {endpoint}")
else:
    sys.exit(f"unexpected endpoint: {endpoint}")

print(json.dumps(result))
