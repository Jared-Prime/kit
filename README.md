[![QA](https://github.com/Jared-Prime/kit/actions/workflows/qa.yml/badge.svg)](https://github.com/Jared-Prime/kit/actions/workflows/qa.yml)
[![OCI](https://github.com/Jared-Prime/kit/actions/workflows/oci.yaml/badge.svg)](https://github.com/Jared-Prime/kit/actions/workflows/oci.yaml)
[![release](https://github.com/Jared-Prime/kit/actions/workflows/release.yml/badge.svg)](https://github.com/Jared-Prime/kit/actions/workflows/release.yml)

A collection of Docker Sandbox Kit (v3) workflows and mixins.

## Quickstart

Each harness — Claude Code, Codex, and opencode — publishes as a single, ready-to-run OCI image, so you don't need to compose kits by hand to get started:

```shell
sbx run 'ghcr.io/jared-prime/sandbox/claude:latest'
```

```shell
sbx run 'ghcr.io/jared-prime/sandbox/codex:latest'
```

```shell
sbx run 'ghcr.io/jared-prime/sandbox/opencode:latest'
```

| harness     | image                                  |
| ----------- | -------------------------------------- |
| Claude Code | `ghcr.io/jared-prime/sandbox/claude`   |
| Codex       | `ghcr.io/jared-prime/sandbox/codex`    |
| opencode    | `ghcr.io/jared-prime/sandbox/opencode` |

## Images and Tags

Every image is built for `linux/amd64` and `linux/arm64`, scanned with Trivy, and published by the [OCI workflow](.github/workflows/oci.yaml).

| tag                    | meaning                                                         |
| ---------------------- | --------------------------------------------------------------- |
| `latest`               | the most recent release                                         |
| `vX.Y.Z`               | a specific release, for example `v2.0.1`                        |
| `dev`                  | the most recent build of `main`                                 |
| `sha-<hash>`           | the build of a specific commit on `main`                        |
| `vX.Y.Z-sha-<short>`   | the same commit build, as the version the kit chain resolves    |

Each tag exists on every image below, under `ghcr.io/jared-prime/`:

| image                                          | contents                                         |
| ---------------------------------------------- | ------------------------------------------------ |
| `sandbox/claude`, `codex`, `opencode`          | the ready-to-run harness (use these)             |
| `kit/workload/anthropic`, `openai`, `anomaly`  | the workload kit for each harness                |
| `kit/mixin/skills`                             | the agent skills mixin (add with `--kit`)        |
| `kit/claude`, `codex`, `opencode`              | the shared tools plus one harness CLI            |
| `kit`                                          | the shared tools only                            |

Merging to `main` publishes `dev`. When release-please cuts a release, the release workflow promotes that commit's already-scanned images to `latest` and `vX.Y.Z` without rebuilding them.

## Development

Use the local directory while developing and testing

```shell
sbx run './anthropic' \
  --kit './skills'
```

## Skills

Load individual skills to share among agents

```shell
sbx agents add jared-prime/kit --skill guided-review
```

## Credentials

The Claude Code and Codex workloads declare an optional host credential.
When bound, the token stays on the host; the sandbox only sees sentinels, and the proxy substitutes the real token.
Sandboxes created afterwards start signed in.

| harness     | token on the host                                        | token in the sandbox only                                                            |
|-------------|----------------------------------------------------------|--------------------------------------------------------------------------------------|
| Claude Code | `/login` once; the proxy captures it                     | decline the `anthropic` credential prompt, then `/login` per sandbox                 |
| Codex       | `sbx secret set -g openai --oauth` (browser on the host) | decline the `openai` credential prompt, then `codex login --device-auth` per sandbox |
| opencode    | not supported                                            | LM Studio takes no login; for OpenCode Zen, sign in per sandbox                      |

To keep a token in the sandbox only, also leave the service unset on the host (`sbx secret ls`).
If you approved the credential before, remove its entry from `~/.config/sbx/credentials.yaml`.
Each harness README shows how to check which token the sandbox holds.

OpenCode Zen models (e.g. `opencode/big-pickle`) need a Zen API key.
`sbx` has no service for it, so the key can only live in the sandbox:
sign in with opencode's login, choose OpenCode Zen, and paste the key in each new sandbox.

All three workloads read the GitHub MCP server's token from the host

```shell
sbx secret set github
```

## Network Policies

A Docker Sandbox applies network access control at two layers:

1. the kit `network-policy` capability declaration
2. the global policy active on the host running `sbx`

One of three presets declare the host policy:

- **open**: all outbound traffic allowed without restriction
- **balanced**: a baseline allowlist covers common development tooling
- **closed**: no baseline allowlist; only kit or user-declared allow rules permitted

A **balanced** policy ships by default.

Allow policies are additive; deny policies are blocking.

### Organization Management

An organization with a paid subscription manages [governance permissions](https://docs.docker.com/ai/sandboxes/governance/access-controls/organization/).
When active, the managed policy replaces the local `sbx` policy entirely.
A kit's `network-policy.allow` declarations and any local machine policies will no longer evaluate.
