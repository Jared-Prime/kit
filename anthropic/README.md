_Note: All commands given from the repository root._

## Build

```shell
docker buildx build -f anthropic/anthropic.yaml -t anthropic:dev anthropic
```

## Usage

Copy your Anthropic API key into the sandbox

```shell
sbx secret set anthropic
```

Run using the local checkout...

```shell
sbx run ./anthropic --name anthropic-gh-test
```

Choose a different default model and effort level

```shell
sbx run ./anthropic --name anthropic-gh-test \
  --kit-arg model=claude-fable-5-1 \
  --kit-arg effort=high
```
