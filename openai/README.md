_Note: All commands given from the repository root._

## Build

## Usage

Run using the local checkout...

```shell
sbx run ./openai --name openai-gh-test
```

## OpenAI Account

Run the login command at startup to authenticate with your ChatGPT account, using
the device-code flow

```shell
codex login --device-auth
```

Plain `codex login` binds its OAuth callback server to `127.0.0.1:1455` inside
the sandbox, which the browser on your host can't reach, so sign-in will fail
with a connection-refused error after you click the link. `--device-auth` avoids
the local callback server entirely.

This kit's network policy allows the ChatGPT OAuth endpoints.
If using the kit in a closed network policy preset, `codex login --device-auth` may fail.
