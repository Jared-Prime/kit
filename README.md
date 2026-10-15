A collection of Docker Sandbox Kit (v3) workflows and mixins.

## Quickstart

```shell
sbx settings set kit.allowedSources '["docker.io/","github.com/jared-prime/","ghcr.io/jared-prime/"]'
sbx run 'ghcr.io/jared-prime/kit-sol:v1.0.0' \
  --kit 'ghcr.io/jared-prime/kit-github:v1.0.0' \
  --kit 'ghcr.io/jared-prime/kit-skills:v1.0.0' \
  --kit-arg gh_repo=jared-prime/kit
```

See [sol/README.md](sol/README.md) for more details on the `codex` workflow.
See [github/README.md](github/README.md) for more details on the `gh` mixin.

## Development

Build and run the kit locally

```shell
sbx run ./sol --name sol-local-development \
  --kit ./github \
  --kit ./skills \
  --kit-arg gh_repo=jared-prime/kit
```

## Skills

Load individual skills to share among agents

```shell
sbx agents add jared-prime/kit --skill guided-review
```
