# TypeScript toolchain

Node.js, pnpm, and the TypeScript compiler are available in this Docker Sandbox kit.

```shell
pnpm install --frozen-lockfile
pnpm run build
tsc --noEmit
```

Network access is scoped to read-only `GET`/`HEAD` on `registry.npmjs.org`.
Installing packages works; publishing, or anything else that writes to the
registry, is blocked by the network policy.

Use `pnpm`, not `npm` or `yarn`, so lockfile resolution stays consistent with
how this kit installs `typescript` globally.
