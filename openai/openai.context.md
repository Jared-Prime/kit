# workload: openai

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

- api.openai.com allows all methods.
- auth.openai.com allows all methods.
- chatgpt.com allows all methods.
- registry.npmjs.org allows GET and HEAD. PATCH, POST, PUT, and DELETE are denied.

Note that some hosts and/or HTTP verbs may be denied by the sandbox network policy or by mixins.

Your codex network permissions defaults to read-only.

### binaries

Before concluding a tool is unavailable because `which` or `find` comes up empty, check whether a mixin's context explains why.
A missing bare binary can be intentional, not absent.
These subsections give definitive information on available binaries and conventions.

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
