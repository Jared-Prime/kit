A collection of Docker Sandbox Kit (v3) workflows and mixins.

## Quickstart

```shell
sbx 'ghcr.io/jared-prime/kit-anthropic:v1.3.0' \
  --kit 'ghcr.io/jared-prime/kit-github:v1.3.0' \
  --kit 'ghcr.io/jared-prime/kit-typescript:v1.3.0' \
  --kit 'ghcr.io/jared-prime/kit-skills:v1.3.0' \
  --kit-arg gh_repo=jared-prime/kit
```

See the [recipes](doc/recipes.md) for more sandbox creation examples.

## Development

Use the local directory while developing and testing

```shell
sbx './anthropic' \
  --kit './github' \
  --kit './typescript' \
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
