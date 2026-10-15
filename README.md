A collection of Docker Sandbox Kit (v3) workflows and mixins.

## Quickstart

After a release containing these changes is published, replace `<release-tag>`
with that release's tag. The existing `v1.1.0` images only support `amd64`.

```shell
sbx settings set kit.allowedSources '["docker.io/","github.com/jared-prime/","ghcr.io/jared-prime/"]'
sbx run 'ghcr.io/jared-prime/kit-sol:<release-tag>' \
  --kit 'ghcr.io/jared-prime/kit-github:<release-tag>' \
  --kit 'ghcr.io/jared-prime/kit-skills:<release-tag>' \
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
