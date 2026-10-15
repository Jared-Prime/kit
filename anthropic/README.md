_Note: All commands given from the repository root._

## Build

```shell
docker buildx build -f anthropic/anthropic.yaml -t anthropic:dev anthropic
```

## Usage

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

## Claude Account

Run the login command at startup to authenticate with your Claude account

```claude-code
/login
```

This kit network policy allows the Claude OAuth endpoints.
If using the kit in a closed network policy preset, the `\login` command may fail.
