[![QA](https://github.com/Jared-Prime/kit/actions/workflows/qa.yml/badge.svg)](https://github.com/Jared-Prime/kit/actions/workflows/qa.yml)
[![dev](https://github.com/Jared-Prime/kit/actions/workflows/dev.yml/badge.svg)](https://github.com/Jared-Prime/kit/actions/workflows/dev.yml)
[![release](https://github.com/Jared-Prime/kit/actions/workflows/release.yml/badge.svg)](https://github.com/Jared-Prime/kit/actions/workflows/release.yml)

A collection of Docker Sandbox Kit (v3) workflows and mixins.

## Quickstart

Each harness — Claude Code, Codex, and opencode — publishes as a single, ready-to-run OCI image, so you don't need to compose kits by hand to get started:

```shell
sbx run 'ghcr.io/jared-prime/harness-claude:v1.8.0'
```

```shell
sbx run 'ghcr.io/jared-prime/harness-codex:v1.8.0'
```

```shell
sbx run 'ghcr.io/jared-prime/harness-opencode:v1.8.0'
```

## Development

Use the local directory while developing and testing

```shell
sbx run './anthropic' \
  --kit './codebase' \
  --kit './github' \
  --kit './python' \
  --kit './skills' \
  --kit-arg gh_repo=jared-prime/kit
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
