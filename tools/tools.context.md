# mixin: tools

## sandbox

This mixin targets Alpine Linux based workloads running in a Docker Sandbox.

### filesystem

Expect Unix permissions for uid/gid 1001.

### binaries

Before concluding a tool is unavailable because `which` or `find` comes up empty, check whether a mixin's context explains why.
A missing bare binary can be intentional, not absent.
These subsections give definitive information on available binaries and conventions.

#### bash

The default shell is bash
```shell
bash --version
```

#### codebase-memory-mcp

Your sandbox mixin pins codebase-memory-mcp to 0.12.1.

```shell
codebase-memory-mcp --version
```

The sandbox mixin does _not_ prepare an MCP for the tool.
Use Bash to run the tool on the command line instead.

#### prek

Your sandbox mixin pins prek to 0.5.7

```shell
prek --version
```

#### node.js

Your sandbox base layer pins to Node.js 26.12.

```bash
node --version
```

#### pnpm

Your sandbox base layer pins to pnpm 12.15.0.

```bash
pnpm --version
```

You **must** use pnpm for Node.js package management.

#### TypeScript

Your sandbox base layer pins to 7.0.2.

```bash
tsc --version
```

#### python

Your sandbox mixin pins python to 3.14.
Always use `uv run python` to invoke python in an active project context:

```shell
uv run python --version
```

Use `uvx` to invoke python outside of an active project context:

```shell
uvx python --version
```

This mixin doesn't put a `python3` binary on `$PATH`.
`uv run`/`uvx` resolve explicitly from this mixin's managed install (`UV_PYTHON_INSTALL_DIR`).
Those commands are unambiguous regardless of what else is on `$PATH`.

#### uv

Your sandbox mixin pins uv to 0.13.6

```shell
uv --version
```

### skills

Use the `introspection` skill to ensure the sandbox has the workload and its mixins configured as expected.

Use the `codebase-memory` skill at least once on the codebase to prepare to the semantic graph.
