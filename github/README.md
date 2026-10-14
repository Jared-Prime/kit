_Note: All commands given from the repository root._

## Build

```shell
docker buildx build -f github/github.yaml -t github:dev github
```

## Usage

Store your local GitHub token for API reads and HTTPS Git fetches.

```shell
sbx secret set github --command 'gh auth token'
```

Run using the local checkout...

```shell
sbx run docker.io/docker/sbx-kit-shell:1.0.0 \
  --name "github-kit-test" \
  --kit ./github \
  --kit-arg gh_repo=Jared-Prime/kit
```

...or from the public repository by first allowing the source

```shell
sbx settings set kit.allowedSources '["docker.io/","github.com/Jared-Prime/"]'
sbx run docker.io/docker/sbx-kit-shell:1.0.0 \
  --name github-from-git-test \
  --kit 'git+https://github.com/Jared-Prime/kit.git&dir=github' \
  --kit-arg gh_repo=Jared-Prime/kit
```

Sanity check the setup

```
✓ agent@github-kit-test:/Users/jared/gitea.com/mathbook.cafe/kit$ gh api user --jq .login
Jared-Prime
```
