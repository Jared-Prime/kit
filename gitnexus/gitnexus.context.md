# mixin: gitnexus

## sandbox

This mixin targets the Alpine Linux, Node.js 26.12 based workloads in this kit (anthropic, openai, anomaly).
It installs into the workload's existing `PNPM_HOME` (`/opt/pnpm`) and relies on the workload's Node.js runtime.

### filesystem

Expect Unix permissions for uid/gid 1001.

GitNexus writes its index to `.gitnexus/` inside each analyzed repository, and its registry to `~/.gitnexus/`.

### network

This mixin declares no network policy of its own.
Indexing and querying run locally.
The npm update check is disabled (`GITNEXUS_NO_UPDATE_NOTIFIER=1`).

These features need network access this mixin does not grant, so expect them to fail unless another kit allows the host:

- `gitnexus wiki` calls a remote LLM.
- `gitnexus auto-sync` clones and pulls Git remotes.
- `gitnexus embeddings install` and `gitnexus analyze --embeddings` fetch an embedding stack from the npm registry.

### binaries

Before concluding a tool is unavailable because `which` or `find` comes up empty, check whether a mixin's context explains why.
A missing bare binary can be intentional, not absent.
These subsections give definitive information on available binaries and conventions.

#### gitnexus

Your sandbox mixin pins gitnexus to 1.6.12.

```shell
gitnexus --version
```

Parsing supports Go, C++, PHP, Java, Ruby, Rust, Python, C#, JavaScript, and TypeScript.
Dart, Proto, Swift, Kotlin, and Zig grammars were skipped at build time, so those languages are not parsed.

By default, `gitnexus analyze` also installs agent skills and hooks and edits `AGENTS.md`/`CLAUDE.md` in the repository.
Ask the user before running it, and check `gitnexus analyze --help` for flags that skip those changes.

```shell
gitnexus analyze            # index the current repository
gitnexus query "<concept>"  # search the graph
gitnexus context <symbol>   # callers, callees, and references for a symbol
gitnexus impact <symbol>    # blast radius of changing a symbol
gitnexus detect-changes     # map the working-tree diff to affected symbols
gitnexus status             # index status for the current repository
```

`gitnexus mcp` runs an MCP server over stdio.
Do not register it with an agent without the user's consent.
