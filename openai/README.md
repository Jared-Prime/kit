_Note: All commands given from the repository root._

## Build

## Usage

Run using the local checkout...

```shell
sbx run ./openai --name openai-gh-test
```

## OpenAI Account

Sign in once on the host with your browser, before creating the sandbox

```shell
sbx secret set -g openai --oauth
```

The token stays on the host; the sandbox only sees sentinels, and the proxy
substitutes the real token for requests to `chatgpt.com`.
An API key bound with `sbx secret set openai` works the same way.
The binding is read at create, so recreate an existing sandbox after signing in.

### Device code

Without a host credential, run the login command at startup to authenticate
with your ChatGPT account, using the device-code flow

```shell
codex login --device-auth
```

Plain `codex login` binds its OAuth callback server to `127.0.0.1:1455` inside
the sandbox, which the browser on your host can't reach, so sign-in will fail
with a connection-refused error after you click the link. `--device-auth` avoids
the local callback server entirely.

This kit's network policy allows the ChatGPT OAuth endpoints.
If using the kit in a closed network policy preset, `codex login --device-auth` may fail.
