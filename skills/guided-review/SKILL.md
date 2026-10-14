---
name: guided-review
description: Guide a staged, conversational acceptance review of a pull request against its ticket, current diff, prior feedback, and CI evidence. Use when the reviewer wants to understand and steward a PR before deciding whether to accept it.
compatibility: Requires git, GitHub CLI (gh), jq, and Shortcut MCP. Scripts use Bash; report formatting uses column and awk; cache inspection uses BSD stat.
---

# Guided PR Acceptance Review

Help the user reach a proportionate pull request acceptance decision.
The user has full responsibility over the pull request.
Do not make any edits to the code or to the pull request.
Do not make any comments, approvals, merges in GitHub.
Do not run tests.
Do not edit tickets.
All your work will be read-only and chat with the user.
Move through the following phases at the user's pace.
Do not treat completion of one phase as permission to start the next.

## Context

Check Shortcut the weekly chore for the user titled `Code Review - YYYY-MM-DD`; make sure this aligns with the context gathered.

Resolve that the GitHub CLI succeeds by using `pull-request-context.sh`.
The script outputs instructions to set `$GH_REPO`, `$GH_USER`, and options for `$GH_TEAM`.
Use the `$GH_REPO` and `$GH_USER` in other scripts as provided by the context script.
Confirm the user's team selection from the options.

Use the `pull-request-report.sh` script to determine which PR available for review.
Confirm the user's pr selection from the options.
Use the confirmed option as `$PR_NUMBER`.

Run `pull-request-checkout.sh` to set the branch for review locally.


## Phase 1: Expectations

Read the following to prepare expectations prior to reading the code:

- ticket
- pull request description
- pull request prior feedback

When the pull request has been stacked, determine which commits and which requirements specifically relate to the target PR.

Write a compact table of acceptance questions tailored to the change.

Use the following format for the table:

|                         | Relevant Questions |
| ----------------------- | ------------------ |
| **Scope of Work**       |                    |
| **Observable Behavior** |                    |
| **Safety**              |                    |
| **Automation**          |                    |
| **Evidence and Tests**  |                    |
Append additional rows if deemed necessary.
State the main acceptance question.
Keep ticket requirements distinct from claims in the PR description; claims still need verification.

Await the user to proceed to the next phase.
## Phase 2: Reading

Determine whether the user has checked out the target branch locally:

```bash
echo "$(git branch --show-current)\t$(git rev-parse HEAD)"
gh pr view --repo "$GH_REPO" "$PR_NUMBER" --json headRefName,headRefOid --jq '[ .headRefName, .headRefOid ] | @tsv'
git status
```

The branch and SHA should match, and there should not be any uncommitted files.

Alternatively, read the diff directly from GitHub

```bash
gh pr diff --repo "$GH_REPO" "$PR_NUMBER"
```

Read the complete relevant diff and any repository guidance that applies to changed files.
Do not alter the worktree.
Provide no analysis or review findings.

If the diff cannot be read, report incomplete simply as "🛑 encountered a problem" then stop.
Otherwise report completion simply as "✅ ready" then stop.
## Phase 3: Review

Work through the expectations from Phase 1, examining one set of questions at a time.

For each row and its questions:

- Explain what the current code and tests demonstrate, with precise file references.
- Identify behavior added beyond the expected scope or expected behavior deferred to another PR.
- Separate implementation concerns from gaps in test evidence. Calibrate certainty and avoid speculative findings.
- Check relevant CI against the current PR head, not an earlier revision, especially when prior feedback concerned failing tests.
- Fetch CI evidence directly with `gh pr view --repo "$GH_REPO" "$PR_NUMBER" --json headRefOid,statusCheckRollup`. Record the head SHA with the evidence and inspect both check runs and status contexts. Recheck `headRefOid` before concluding; if it changed, refresh the evidence. Use cached PR-list scripts only for triage.
- Reconsider conclusions when the reviewer challenges them or supplies new evidence.

Keep the exchange conversational.
Do not turn every observation into a GitHub comment.
When a comment is warranted, suggest the exact diff location and concise wording; let the reviewer decide whether to post it.

## 4. Summarize

After the point-by-point discussion, write a `## Summary` that reflects the review actually conducted.
Cover the PR's purpose, material behavior and scope, operational impact, evidence from the current head, and any unresolved acceptance question.
Do not imply approval merely because CI passed or most criteria were met.
Do not introduce new findings in the summary without first examining them with the reviewer.

Create a memory for this review.
Include the Expectations and Summarization, as well as any decisions taken during the session.

---

# Scripts

Use the following scripts in this skill package for read-only information on the git repository.

|                                  | purpose                                                                                                               |
|----------------------------------|-----------------------------------------------------------------------------------------------------------------------|
| pull-request-approval-needed.sh  | Check that the pull request actually ready for approval; this short-circuits effort in case the review is redundant.  |
| pull-request-attention-needed.sh | Check that the pull request may have conflicts or failed GitHub Action; this anticipates problems in the pushed code. |
| pull-request-traffic.sh          | Find files changed by multiple open pull requests.                                                                    |

`pull-request-report.sh` writes a cache under `/tmp`; it is a user-run utility and is not one of the read-only agent scripts above.


# References

Use the following for preferred behavior using `git` and `gh`.
Any scenario where an Agent may act, so may a user.
Any scenario where a User may act, the Agent may not.
The Agent may advise in all scenarios but not necessarily act.

| scenario                                                                                                | instructions            | actor |
|---------------------------------------------------------------------------------------------------------|-------------------------|-------|
| How do I confirm I've checked out the correct branch?                                                   | [[git-checkout]]        | Agent |
| How do I checkout a remote branch?                                                                      | [[git-checkout]]        | User  |
| How can I list open pull requests on a repository?                                                      | [[pull-request-list]]   | Agent |
| How can I list open pull requests for just myself or my team?                                           | [[pull-request-review]] | Agent |
| How can I list open pull requests with no reviewers?                                                    | [[pull-request-review]] | Agent |
| How can I see the GitHub Action status on pull requests?                                                | [[pull-request-review]] | Agent |
| How can I get more details on a pull requests?                                                          | [[pull-request-review]] | Agent |
| How can I list open pull requests GitHub reports as mergeable?                                          | [[pull-request-review]] | Agent |
| How can I list open pull requests that have conflicts?                                                  | [[pull-request-review]] | Agent |
| How can I get the diff for a specific branch?                                                           | [[pull-request-review]] | Agent |
| How can I get the file change list for a pull request?                                                  | [[pull-request-review]] | Agent |
| How can I flatten output for further analysis?                                                          | [[pull-request-manage]] | User  |
| How can I highlight pull requests from saved data that requires attention?                              | [[pull-request-manage]] | Agent |
| How can I highlight pull requests from saved data with successful check runs and no reported conflicts? | [[pull-request-manage]] | Agent |
| How can I find files changed by more than one open pull request?                                        | [[pull-request-manage]] | Agent |
