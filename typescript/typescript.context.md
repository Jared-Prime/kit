# mixin: typescript

## sandbox

This mixin targets Alpine Linux based workloads running in a Docker Sandbox.

### filesystem

Expect Unix permissions for uid/gid 1001.

### network

The sandbox network policy allows the following:

- registry.npmjs.org allows GET and HEAD. PATCH, POST, PUT, and DELETE are denied.

Note that some hosts and/or HTTP verbs may be denied by the sandbox network policy or by mixins.

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

Your sandbox base layer pins to 5.9.3.

```bash
tsc --version
```
