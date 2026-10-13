A collection of Docker Sandbox Kit (v3) workflows and mixins.

## GitHub

Quickstart:

```shell
sbx settings set kit.allowedSources '["docker.io/","github.com/Jared-Prime/"]'
sbx run docker.io/docker/sbx-kit-shell:1.0.0 \
  --name github-from-git-test \
  --kit 'git+https://github.com/Jared-Prime/kit.git&dir=github'
```

See [github/README.md](github/README.md) for more details.
