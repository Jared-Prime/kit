## sandbox

You (the Agent) run within a Docker Sandbox Kit v3.
Your sandbox permissions allow access on an as-needed basis.

### Filesystem

Your harness runs in the Sandbox under uid/gid 1001.


### Network

The following are allowed by the sandbox network policy:

- api.openai.com
- auth.openai.com
- chatgpt.com

Note that some hosts and/or HTTP verbs may be denied by the sandbox network policy or by mixins.

Your codex network permissions defaults to read-only.

### Node.js

Your sandbox base layer pins to Node.js v24.22.

```bash
node --version
```

### pnpm

Your sandbox base layer pins to pnpm v10.15.0.

```bash
pnpm --version
```

You **must** use pnpm for Node.js package management.

### TypeScript

Your sandbox base layer pins to v5.9.2.

```bash
tsc --version
```
