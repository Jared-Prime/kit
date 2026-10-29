[![QA](https://github.com/Jared-Prime/kit/actions/workflows/qa.yml/badge.svg)](https://github.com/Jared-Prime/kit/actions/workflows/qa.yml)
[![OCI](https://github.com/Jared-Prime/kit/actions/workflows/oci.yaml/badge.svg)](https://github.com/Jared-Prime/kit/actions/workflows/oci.yaml)
[![release](https://github.com/Jared-Prime/kit/actions/workflows/release.yml/badge.svg)](https://github.com/Jared-Prime/kit/actions/workflows/release.yml)

A collection of Docker Sandbox Kit (v3) workflows and mixins.

## Quickstart

Each harness — Claude Code, Codex, and opencode — publishes as a single, ready-to-run OCI image, so you don't need to compose kits by hand to get started:

```shell
sbx run 'ghcr.io/jared-prime/sandbox/anthropic:latest'
```

```shell
sbx run 'ghcr.io/jared-prime/sandbox/openai:latest'
```

```shell
sbx run 'ghcr.io/jared-prime/sandbox/anomaly:latest'
```

| harness     | image                                   |
| ----------- | --------------------------------------- |
| Claude Code | `ghcr.io/jared-prime/sandbox/anthropic` |
| Codex       | `ghcr.io/jared-prime/sandbox/openai`    |
| opencode    | `ghcr.io/jared-prime/sandbox/anomaly`   |

## Images and Tags

Every image is built for `linux/amd64` and `linux/arm64`, scanned with Trivy, and published by the [OCI workflow](.github/workflows/oci.yaml).

| tag          | meaning                                                  |
| ------------ | -------------------------------------------------------- |
| `latest`     | the most recent release                                  |
| `vX.Y.Z`     | a specific release, for example `v2.0.1`                 |
| `dev`        | the most recent build of `main`                          |
| `sha-<hash>` | the build of a specific commit on `main`                 |

Each tag exists on every image below, under `ghcr.io/jared-prime/`:

| image                                       | contents                                      |
| ------------------------------------------- | --------------------------------------------- |
| `sandbox/anthropic`, `openai`, `anomaly`    | the ready-to-run harness (use these)          |
| `workload/anthropic`, `openai`, `anomaly`   | the workload kit: harness plus kit descriptor |
| `kit/claude`, `codex`, `opencode`           | the shared tools plus one harness CLI         |
| `kit`                                       | the shared tools only                         |
| `skills`                                    | the agent skills mixin (add with `--kit`)     |

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
