# workload: openai

## sandbox

You (the Agent) run within a Docker Sandbox Kit v3.
Your sandbox permissions allow access on an as-needed basis.
Check the workload and/or mixin context for preferred command instructions.
Check the workload and/or mixin `provides` metadata for available binaries.
If neither the context nor the `provides` indicates that the sandbox has a binary available, it's likely unavailable.

### filesystem

Your harness runs in the sandbox under uid/gid 1000.

### network

The sandbox network policy allows the following:

- api.openai.com allows all methods.
- auth.openai.com allows all methods.
- chatgpt.com allows all methods.
- api.githubcopilot.com allows all methods (GitHub MCP server, read-only via the `X-MCP-Readonly` header; authenticated by the proxy-managed `GITHUB_PAT_TOKEN`).
- registry.npmjs.org, pypi.org, and files.pythonhosted.org allow GET and HEAD. PATCH, POST, PUT, and DELETE are denied.

Note that some hosts and/or HTTP verbs may be denied by the sandbox network policy or by mixins.

Your codex network permissions defaults to read-only.

### binaries

Before concluding a tool is unavailable because `which` or `find` comes up empty, check whether a mixin's context explains why.
A missing bare binary can be intentional, not absent.
These subsections give definitive information on available binaries and conventions.

#### bash

The default shell is bash.

```shell
bash --version
```

#### codebase-memory-mcp

Your sandbox workload pins codebase-memory-mcp to 0.12.1.

```shell
codebase-memory-mcp --version
```

The sandbox does _not_ prepare an MCP for the tool.
Use Bash to run the tool on the command line instead.

#### node.js

Your sandbox workload pins Node.js to 26.12.

```bash
node --version
```

#### pnpm

Your sandbox workload pins pnpm to 12.15.0.

```bash
pnpm --version
```

You **must** use pnpm for Node.js package management.

#### prek

Your sandbox workload pins prek to 0.5.7.

```shell
prek --version
```

#### python

Your sandbox workload pins python to 3.14.
Always use `uv run python` to invoke python in an active project context:

```shell
uv run python --version
```

Use `uvx` to invoke python outside of an active project context:

```shell
uvx python --version
```

The sandbox doesn't put a `python3` binary on `$PATH`.
`uv run`/`uvx` resolve explicitly from the managed install (`UV_PYTHON_INSTALL_DIR`).
Those commands are unambiguous regardless of what else is on `$PATH`.

#### TypeScript

Your sandbox workload pins TypeScript to 7.0.2.

```bash
tsc --version
```

#### uv

Your sandbox workload pins uv to 0.13.6.

```shell
uv --version
```

### skills

The `skills` mixin provides the following skills when it is composed with this workload.

Use the `introspection` skill to ensure the sandbox has the workload and its mixins configured as expected.

Use the `codebase-memory` skill at least once on the codebase to prepare the semantic graph.

### mcp

#### github

The workload configures the remote GitHub MCP server (`https://api.githubcopilot.com/mcp/`) as `mcp_servers.github`, replacing the `gh` CLI.
It is read-only (`X-MCP-Readonly: true`) and authenticates with the proxy-managed `GITHUB_PAT_TOKEN`.
Use the MCP tools for GitHub access; do not use `gh` or `git push`.

Check that the server is configured and connected:

```shell
codex mcp list
codex mcp get github
```

Verify access with a read-only MCP tool call, such as getting the authenticated user.
If the server is missing or unauthorized, report the error rather than changing the network policy or config.
Never print or save `GITHUB_PAT_TOKEN`.
