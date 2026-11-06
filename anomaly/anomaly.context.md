# workload: anomaly

## sandbox

You (the Agent) run within a Docker Sandbox Kit v3.
Your sandbox permissions allow access on an as-needed basis.
Check the workload and/or mixin context for preferred command instructions.
Check the workload and/or mixin `provides` metadata for available binaries.
If neither the context nor the `provides` indicates that the sandbox has a binary available, it's likely unavailable.

### filesystem

Your harness runs in the sandbox under uid/gid 1000.

### network

| host                   |            | HEAD  | GET   | PATCH | POST  | PUT   | DELETE |
|------------------------|------------|-------|-------|-------|-------|-------|--------|
| opencode.ai            |            | allow | allow | allow | allow | allow | allow  |
| localhost:1234         | LM Studio  | allow | allow | allow | allow | allow | allow  |
| api.githubcopilot.com  | GitHub MCP | allow | allow | allow | allow | allow | allow  |
| registry.npmjs.org     |            | allow | allow | deny  | deny  | deny  | deny   |
| pypi.org               |            | allow | allow | deny  | deny  | deny  | deny   |
| files.pythonhosted.org |            | allow | allow | deny  | deny  | deny  | deny   |

Note: GitHub MCP has a read-only configuration despite allowing all HTTP methods; the sandbox injects a `X-MCP-Readonly` header.

Some hosts and/or HTTP verbs may be denied by the host sandbox network policies or by additional mixins.

### binaries

Before concluding a tool is unavailable because `which` or `find` comes up empty, check whether a mixin's context explains why.
A missing bare binary can be intentional, not absent.
These subsections give definitive information on available binaries and conventions.

#### bash

```shell
bash --version
# GNU bash, version 5.3.9
```

#### codebase-memory-mcp

```shell
codebase-memory-mcp --version
# codebase-memory-mcp 0.12.1
```

The sandbox does _not_ prepare an MCP for the tool.
Use Bash to run the tool on the command line instead.

#### curl

```shell
curl --version
# curl 8.23.0
```

Sandbox network policies still applies to curl invocations.

#### git

```shell
git --version
# git version 2.55.0
```

#### jq

```shell
jq --version
# jq-1.8.2
```

#### node.js

```bash
node --version
# v26.13.0
```

#### opencode

```bash
opencode --version
# opencode v2.2.5
```

#### pnpm

```bash
pnpm --version
# 12.16.1
```

You **must** use pnpm for Node.js package management.

#### prek

```shell
prek --version
# prek 0.5.10
```

#### python

The `python3` binary does not exist on `$PATH`.
Always use `uv run python` to invoke python in an active project context:

```shell
uv run python --version
# Python 3.15
```

Use `uvx` to invoke python outside an active project context:

```shell
uvx python --version
# Python 3.15
```

`uv run`/`uvx` resolve explicitly from the managed install (`UV_PYTHON_INSTALL_DIR`).
Those commands are unambiguous regardless of what else is on `$PATH`.

#### ripgrep

```shell
rg --version
# ripgrep 15.1.0
```

#### TypeScript

```bash
tsc --version
# Version 7.0.2
```

#### uv

```shell
uv --version
# uv 0.13.7
```

### mcp

```shell
opencode mcp list
```

#### github

Do not use `gh` or `git push`.
Use the GitHub MCP for reading project data; authentication is managed by the proxy using `GITHUB_PAT_TOKEN`.
Never print or save `GITHUB_PAT_TOKEN`.
The sandbox user **should** supply a personal access token with read-only scope.

Verify access with a read-only MCP tool call, such as getting the authenticated user.
If the server is missing or unauthorized, report the error rather than changing the network policy or config.
