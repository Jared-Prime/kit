## Build

## Usage

Copy your local GitHub API authorization token into the sandbox.

```shell
sbx secret set github --command 'gh auth token'
```

Start the sandbox with the mixin active

```shell
sbx run docker.io/docker/sbx-kit-shell:1.0.0 \
  --name "github-kit-test"
  --kit ./github
```

Sanity check the setup

```
✓ agent@github-kit-test:/Users/jared/gitea.com/mathbook.cafe/kit$ gh api user --jq .login
Jared-Prime
```
