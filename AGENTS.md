# jared-prime/kit

This project follows the Docker Sandbox Kit (v3) specification.

The project defines reusable kit mixins and preferred agentic workloads, publishing the layers as OCI artifacts.

Conventions in this repository follow the maintainer's personal preferences.

## Project Directory

| folder    | kit type | core functionality                                                   |
| --------- | -------- | -------------------------------------------------------------------- |
| anomaly   | workload | `opencode`                                                           |
| anthropic | workload | `claude`                                                             |
| openai    | workload | `codex`                                                              |
| skills    | mixin    | agent skills                                                         |

The root `Dockerfile` builds the shared tools (`bash`, `git`, `jq`, `rg`, `node`, `pnpm`, `uv`, `prek`, `codebase-memory-mcp`) and each harness CLI as the `kit` images.
Each workload builds on its harness image, so the tools ship inside the workload rather than as a mixin.

## Development

Agents must not commit directly; Users should use commit signatures with an external SSH client (e.g. 1Password).
Every commit should involve a review by the Agent; this review should use `git diff *` or `git log *` with standard read tools.

Run static checks after making a change:

```shell
prek run -a
```

Before the User performs a commit, the agent should engage the `commit-message` skill to recommend a message.

### Language Conventions

Preferred language conventions (Python via `uv`, Node.js via `pnpm`) are documented in each workload's context:

* [Anthropic](anthropic/anthropic.context.md)
* [OpenAI](openai/openai.context.md)
* [Anomaly](anomaly/anomaly.context.md)

## Additional Internal References

* [Maintainers](.github/MAINTAINERS.md)
* [README](README.md)
* [Security](.github/SECURITY.md)
* [`commit-message`](skills/commit-message/SKILL.md)

## Additional External References

Fetch these references via built-in tools only when additional information needed on the topic:

* 1Password: Sign Git commits with SSH https://www.1password.dev/ssh/git-commit-signing
* Docker Sandbox Kit (v3) Specification https://github.com/docker/sandbox-kit-spec
* Git Tools: Signing Your Work https://git-scm.com/book/ms/v2/Git-Tools-Signing-Your-Work
