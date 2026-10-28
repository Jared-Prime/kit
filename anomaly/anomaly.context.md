# workload: anomaly

## sandbox

You (the Agent) run within a Docker Sandbox Kit v3.
Your sandbox permissions allow access on an as-needed basis.
Check the workload and/or mixin context for preferred command instructions.
Check the workload and/or mixin `provides` metadata for available binaries.
If neither the context nor the `provides` indicates that the sandbox has a binary available, it's likely unavailable.

### filesystem

Your harness runs in the sandbox under uid/gid 1001.

### network

The sandbox network policy allows the following:

- opencode.ai allows all methods.
- localhost:1234 allows all methods (LM Studio; the agent reaches it as `host.docker.internal:1234`).
- api.githubcopilot.com allows all methods (GitHub MCP server, read-only via the `X-MCP-Readonly` header; authenticated by the proxy-managed `GITHUB_PAT_TOKEN`).
- registry.npmjs.org, pypi.org, and files.pythonhosted.org allow GET and HEAD. PATCH, POST, PUT, and DELETE are denied.

Note that some hosts and/or HTTP verbs may be denied by the sandbox network policy or by mixins.

### binaries

Before concluding a tool is unavailable because `which` or `find` comes up empty, check whether a mixin's context explains why.
A missing bare binary can be intentional, not absent.
These subsections give definitive information on available binaries and conventions.

#### bash

The default shell is bash

```shell
bash --version
```

#### opencode

Your sandbox workload pins opencode to 2.0.32.

```shell
opencode --version
```

#### pnpm

Your sandbox base layer pins to pnpm 12.15.0.

```bash
pnpm --version
```

You **must** use pnpm for Node.js package management.

### mcp

#### github

The workload configures the remote GitHub MCP server (`https://api.githubcopilot.com/mcp/`) as the `github` MCP server, replacing the `gh` CLI.
It is read-only (`X-MCP-Readonly: true`) and authenticates with the proxy-managed `GITHUB_PAT_TOKEN`.
Use the MCP tools for GitHub access; do not use `gh` or `git push`.

Check that the server is configured and connected:

```shell
opencode mcp list
```

Verify access with a read-only MCP tool call, such as getting the authenticated user.
If the server is missing or unauthorized, report the error rather than changing the network policy or config.
Never print or save `GITHUB_PAT_TOKEN`.
