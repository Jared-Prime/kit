---
name: codebase-memory
description: Perform a codebase index or search on the current working directory
---

Keep a separate cached index by exporting the `CBM_CACHE_DIR` environment variable.

```bash
export CBM_CACHE_DIR="/home/agent/.cache/codebase-memory-mcp/$(git rev-parse --abbrev-ref HEAD)"
```

Create or update the source index.

```bash
codebase-memory-mcp cli index_repository --repo-path "$(pwd)"
```

List indexed projects

When in trouble, review the current version and commands for the utility.

```bash
codebase-memory-mcp --version
codebase-memory-mcp cli --help
```
