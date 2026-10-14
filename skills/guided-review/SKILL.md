---
name: guided-review
description: Guide a staged, conversational acceptance review of a pull request against its ticket, current diff, prior feedback, and CI evidence. Use when the reviewer wants to understand and steward a PR before deciding whether to accept it.
compatibility: Requires git, GitHub CLI (gh), jq, and Shortcut MCP. Scripts use Bash; report formatting uses column and awk; cache inspection uses BSD stat.
---

# Guided Review

Help the user reach a proportionate pull request acceptance decision.
The user has full responsibility over the pull request.
Do not make any edits to the code or to the pull request.
Do not make any comments, approvals, merges in GitHub.
Do not run tests; use evidence found in CI instead.
Do not edit tickets.
All your work will be read-only and chat with the user.
Move through the following phases at the user's pace.
Do not treat completion of one phase as permission to start the next.

## Phase 0: Setup

1. run `scripts/context.sh` and refer to the output for the other commands
2. run `scripts/available.sh` then ask the user to select an available pull request
3. run `scripts/checkout.sh` using the output from (1) and the selection from (2) as `GH_HEAD`

A copy of the `main` and the reviewable branch can be found in the specified location from (3).

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

## Phase 2: Silent Reading

Read the complete relevant diff and any repository guidance that applies to changed files.
Do not alter the worktree.
Provide no analysis or review findings.
Report completion simply as "✅ ready" then stop.

## Phase 3: Point-by-Point Expectation Check

Work through the expectations from Phase 1, examining one set of questions at a time.

For each row and its questions:

- Explain what the current code and tests demonstrate, with precise file references.
- Identify behavior added beyond the expected scope or expected behavior deferred to another PR.
- Separate implementation concerns from gaps in test evidence. Calibrate certainty and avoid speculative findings.
- Check relevant CI against the current PR head, not an earlier revision, especially when prior feedback concerned failing tests.
- Reconsider conclusions when the reviewer challenges them or supplies new evidence.

Keep the exchange conversational.
Do not turn every observation into a GitHub comment.
When a comment is warranted, suggest the exact diff location and concise wording; let the reviewer decide whether to post it.

## Phase 4: Summary

After the point-by-point discussion, write a `## Summary` that reflects the review actually conducted.
Cover the PR's purpose, material behavior and scope, operational impact, evidence from the current head, and any unresolved acceptance question.
Do not imply approval merely because CI passed or most criteria were met.
Do not introduce new findings in the summary without first examining them with the reviewer.
