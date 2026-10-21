# mixin: python

## sandbox

This mixin targets Alpine Linux based workloads running in a Docker Sandbox.

### filesystem

Expect Unix permissions for uid/gid 1001.

### network

The sandbox network policy allows the following:

- pypi.org allows GET and HEAD. PATCH, POST, PUT, and DELETE are denied.
- files.pythonhosted.org allows GET and HEAD. PATCH, POST, PUT, and DELETE are denied.
- github.com allows GET and HEAD, restricted to `/astral-sh/python-build-standalone/releases/download/**`. PATCH, POST, PUT, and DELETE are denied.
- objects.githubusercontent.com allows GET and HEAD. PATCH, POST, PUT, and DELETE are denied.

Note that some hosts and/or HTTP verbs may be denied by the sandbox network policy or by mixins.

### binaries

Before concluding a tool is unavailable because `which` or `find` comes up empty, check whether a mixin's context explains why.
A missing bare binary can be intentional, not absent.
These subsections give definitive information on available binaries and conventions.

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

Your sandbox mixin pins uv to 0.13.4

```shell
uv --version
```
