A collection of Docker Sandbox Kit (v3) workflows and mixins.

## Quickstart

Each harness — Claude Code, Codex, and opencode — publishes as a single, ready-to-run OCI image, so you don't need to compose kits by hand to get started:

```shell
sbx 'ghcr.io/jared-prime/harness-claude:v1.5.2' --kit-arg gh_repo=jared-prime/kit
```

```shell
sbx 'ghcr.io/jared-prime/harness-codex:v1.5.2' --kit-arg gh_repo=jared-prime/kit
```

```shell
sbx 'ghcr.io/jared-prime/harness-opencode:v1.5.2' --kit-arg gh_repo=jared-prime/kit
```

See the [recipes](doc/recipes.md) for more sandbox creation examples, or [compose your own kit set](#compose-your-own-kit-set) below.

## Development

Use the local directory while developing and testing

```shell
sbx './anthropic' \
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

# recipes

## Compose your own kit set

Each harness image is just a published bundle of individual kits. Mix and match them yourself if you want a different combination — e.g. swap `kit-python` for a different mixin, or drop `kit-skills` entirely:

```shell
sbx 'ghcr.io/jared-prime/kit-anthropic:v1.5.2' \
  --kit 'ghcr.io/jared-prime/kit-github:v1.5.2' \
  --kit 'ghcr.io/jared-prime/kit-python:v1.5.2' \
  --kit 'ghcr.io/jared-prime/kit-skills:v1.5.2'
```

```shell
sbx 'ghcr.io/jared-prime/kit-openai:v1.5.2' \
  --kit 'ghcr.io/jared-prime/kit-github:v1.5.2' \
  --kit 'ghcr.io/jared-prime/kit-python:v1.5.2' \
  --kit 'ghcr.io/jared-prime/kit-skills:v1.5.2'
```

Add `ghcr.io/jared-prime/kit-typescript:v1.5.2` as its own `--kit` if your composition needs a standalone Node/pnpm/TypeScript toolchain — `kit-anthropic` and `kit-openai` already bundle their own, so it isn't required for the recipes above.
