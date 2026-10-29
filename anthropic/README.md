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

### Shell commands

Start a prompt with `!` to run a shell command in the sandbox from within Claude Code.
The command and its output land in the conversation.

```claude-code
! ls -la ~/.claude
```

From the host, run the same command with `sbx exec`

```shell
sbx exec anthropic-gh-test sh -c 'ls -la ~/.claude'
```

## Claude Account

Run the login command at startup to authenticate with your Claude account

```claude-code
/login
```

The proxy intercepts the token exchange, so the token stays on the host and
the sandbox only sees sentinels in `~/.claude/.credentials.json`.
Sandboxes created afterwards start signed in.

Check for the sentinels; only the token prefix is printed, so a real token doesn't land in the conversation

```claude-code
! jq -r '.claudeAiOauth | .accessToken[0:28], .refreshToken[0:28]' ~/.claude/.credentials.json
```

Expect `sk-ant-oat01-proxy-managed` and `sk-ant-ort01-proxy-managed`.
Random characters after the `sk-ant-oat01-` prefix mean the real token reached the sandbox.

Alternatively, bind an API key on the host before creating the sandbox

```shell
sbx secret set anthropic
```

This kit network policy allows the Claude OAuth endpoints.
If using the kit in a closed network policy preset, the `\login` command may fail.
