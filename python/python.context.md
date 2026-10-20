## Installed

Python 3.14 and uv 0.13.4 are available as a mixin in this Docker sandbox
kit, overlaid onto whatever workload it's composed with. `git` and `jq` are
not provided by this mixin; they come from the workload.

This kit targets Alpine-based (musl libc) workloads only. The Python
interpreter is built against musl, and the mixin does not bundle a musl
runtime for non-Alpine workloads, so it is not portable to glibc-based
(e.g. Debian/Ubuntu) workloads.

```shell
uv --version
uv run python --version
```

Always invoke Python through `uv run python` (or `uvx`), never a bare
`python`/`python3`. This mixin doesn't put a `python3` binary on `$PATH` — if
the workload it's composed with already ships its own OS-level Python, a bare
`python3` could silently resolve to that one instead of the version this
mixin installs. `uv run`/`uvx` resolve explicitly from this mixin's managed
install (`UV_PYTHON_INSTALL_DIR`), so they're unambiguous regardless of what
else is on `$PATH`.

Network access is scoped to read-only `GET`/`HEAD` on `pypi.org` and
`files.pythonhosted.org` for packages, plus `github.com` (restricted to
`/astral-sh/python-build-standalone/releases/download/**`) and
`objects.githubusercontent.com` (GitHub's release-asset redirect target, whose
paths are opaque and signed per-request so they can't be usefully scoped
further) so `uv python install` can fetch Python distributions. Installing
packages and Python versions works; publishing, or anything else that writes
to these hosts, is blocked by the network policy.
