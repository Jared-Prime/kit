A collection of Docker Sandbox Kit (v3) workflows and mixins.

## Quickstart

After a release containing these changes is published, replace `<release-tag>`
with that release's tag. The existing `v1.1.0` images only support `amd64`.

```shell
sbx settings set kit.allowedSources '["docker.io/","github.com/jared-prime/","ghcr.io/jared-prime/"]'
sbx run 'ghcr.io/jared-prime/kit-openai:<release-tag>' \
  --kit 'ghcr.io/jared-prime/kit-github:<release-tag>' \
  --kit 'ghcr.io/jared-prime/kit-skills:<release-tag>' \
  --kit-arg gh_repo=jared-prime/kit
```

...or with Claude Code

```shell
sbx run 'ghcr.io/jared-prime/kit-anthropic:<release-tag>' \
  --kit 'ghcr.io/jared-prime/kit-github:<release-tag>' \
  --kit 'ghcr.io/jared-prime/kit-skills:<release-tag>' \
  --kit-arg gh_repo=jared-prime/kit
```

See [openai/README.md](openai/README.md) for more details on the `codex` workflow.
See [anthropic/README.md](anthropic/README.md) for more details on the `claude` workflow.
See [github/README.md](github/README.md) for more details on the `gh` mixin.

## Development

Build and run the kit locally

```shell
sbx run ./openai --name openai-local-development \
  --kit ./github \
  --kit ./skills \
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
