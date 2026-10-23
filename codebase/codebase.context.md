# mixin: codebase

## sandbox

This mixin targets Alpine Linux based workloads running in a Docker Sandbox.
It adds a single statically linked binary and has no runtime dependencies.

### filesystem

Expect Unix permissions for uid/gid 1001.

Indexes and configuration are stored in `~/.cache/codebase-memory-mcp/` (override with `CBM_CACHE_DIR`), not in the repository.

### network

This mixin declares no network policy.
codebase-memory-mcp indexes and queries locally and makes no network requests of its own.

### binaries

Before concluding a tool is unavailable because `which` or `find` comes up empty, check whether a mixin's context explains why.
A missing bare binary can be intentional, not absent.
These subsections give definitive information on available binaries and conventions.

#### codebase-memory-mcp

Your sandbox mixin pins codebase-memory-mcp to 0.12.1.

```shell
codebase-memory-mcp --version
```

The sandbox mixin does _not_ prepare an MCP for the tool.
Use Bash to run the tool on the command line instead.

```bash
codebase-memory-mcp cli --help
```

##### Index

Create or update a source code index

```bash
codebase-memory-mcp cli index_repository --repo-path /path/to/repo
```

List indexed projects

```bash
codebase-memory-mcp cli list_projects
```

##### Search

Search the knowledge graph for a pattern by project

```bash
codebase-memory-mcp cli search_graph --project my-project --name-pattern '.*Handler.*' --label Function
```

Trace usage of a function through the codebase

```bash
codebase-memory-mcp cli trace_path --project my-project --function-name Search --direction both
```

Query the knowledge graph

```bash
codebase-memory-mcp cli query_graph --project my-project --query 'MATCH (f:Function) RETURN f.name LIMIT 5'
```

##### Graph Data Model

###### Node Labels

Project, Package, Folder, File, Module, Section, Class, Struct, Interface, Trait, Enum, Type, Function, Method, Field, Variable, Constant, Macro, Decorator, Route, Channel, Table, Process, EnvVar, Resource, Chart, Image, Branch

###### Edge Types

CONTAINS_FOLDER, CONTAINS_FILE, DEFINES, DEFINES_METHOD, IMPORTS, CALLS, CALL_REFERENCE, USAGE, INHERITS, IMPLEMENTS, OVERRIDE, DECORATES, RAISES, THROWS, WRITES, DATA_FLOWS, HTTP_CALLS, GRPC_CALLS, ASYNC_CALLS, EMITS, LISTENS_ON, HANDLES, SPAWNS, CONFIGURES, INFRA_MAPS, CONNECTS_TO, DEPLOYS, DEPENDS_ON, REFERENCES_FILE, MENTIONS, TESTS, TESTS_FILE, SIMILAR_TO, SEMANTICALLY_RELATED, FILE_CHANGES_WITH, HAS_BRANCH, and the cross-repo CROSS_HTTP_CALLS, CROSS_GRPC_CALLS, CROSS_GRAPHQL_CALLS, CROSS_TRPC_CALLS, CROSS_ASYNC_CALLS, CROSS_CHANNEL

##### Languages

Well-supported grammars are

- Bash
- CSS
- YAML
- TOML
- HTML
- HCL
- Dockerfile

Other supported grammars are

- Python
- TypeScript
- Go
- Rust
- JavaScript
- Ruby
- SQL

###### Hybrid LSP

Some programming languages have a full hybrid LSP shipped with the `codebase-memory-mcp` binary.

- C / C++
- Python
- TypeScript
- Go
- Rust

The tool performs a two-layer pass: (1) tree-sitter then (2) LSP resulting in a knowledge graph traversal.
