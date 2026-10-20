---
name: commit-message
description: Draft a git commit message with a Conventional Commits header and a Co-Authored-By trailer in the `<harness> (<model>) <email>` format. Use when the user asks you to draft, write, or suggest a commit message, with or without actually committing.
compatibility: Requires git.
context: fork
background: false
---

# Commit Message

Draft a commit message for the current changes.
Do not run `git commit`.

## Phase 1: Context

Run in parallel:

- `git status` to list staged and untracked files
- `git diff` for both staged and unstaged changes
- `git diff --staged` for only staged changes
- `git log --oneline -10` to recall this repo's existing message style (capitalization, scope conventions, line length)

## Phase 2: Header

Format: `<type>(<scope>): <description>`

- `type` is one of: `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `build`, `ci`, `chore`. Pick the one that matches the *nature* of the change, not its size.
- `scope` is optional; include it when the change is clearly confined to one area (a kit name, a module, a package). Omit it when the change spans multiple scopes.
- `description` is imperative mood, lowercase, no trailing period, under ~70 characters total for the header line.

## Phase 3: Body

1-2 sentences focused on *why*, not a restatement of the diff.
Add a body only if the header doesn't already carry enough context.
Do not pad a self-explanatory change.

## Phase 4: Trailer

Determine `<harness>`, `<model>`, and `<email>` from the current session.
Use proper names in the harness and model fields (e.g. `Claude Code (Sonnet 5)`), not internal slugs or model IDs.
If no attribution context is available in the session, ask the user for these values rather than guessing.

When the agent has performed changes, add:

```
Co-Authored-By: <harness> (<model>) <email>
```

When the agent has reviewed changes, add:

```
Reviewed-by: <harness> (<model>) <email>
```

When the agent has done neither edits nor reviews, skip the trailer.

### Reference Table: Harness, Model, Email

The repository for this SKILL (`github.com/Jared-Prime/kit`) supports the following agent configurations:

| harness     | model     | email                 |
|-------------|-----------|-----------------------|
| Claude Code | Sonnet 5  | noreply@anthropic.com |
| Codex       | GPT-6 Sol | noreply@openai.com    |
| Opencode    | Qwen 3.8  | noreply@opencode.ai   |

## Phase 5: Present

Show the drafted message to the user.
Do not run `git commit`.
