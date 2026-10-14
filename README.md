A collection of Docker Sandbox Kit (v3) workflows and mixins.

## Quickstart

```shell
sbx settings set kit.allowedSources '["docker.io/","github.com/Jared-Prime/"]'

sbx run 'git+https://github.com/Jared-Prime/kit.git#ref=main&dir=sol' \
  --name sol-with-gh \
  --kit 'git+https://github.com/Jared-Prime/kit.git#ref=main&dir=github'
```

See [github/README.md](github/README.md) for more details on the `gh` mixin.
See [sol/README.md](sol/README.md) for more details on the `codex` workflow.

## Skills

Add a skill from this repository to your sandbox

```shell
sbx agents add Jared-Prime/kit --skill guided-review
```
