## Installed

Python 3.14 and uv 0.13.3 are available in this Docker sandbox kit.

```shell
uv --version
```

Network access is scoped to read-only `GET`/`HEAD` on `pypi.org` and
`files.pythonhosted.org` for packages, plus `github.com` (restricted to
`/astral-sh/python-build-standalone/releases/download/**`) and
`objects.githubusercontent.com` (GitHub's release-asset redirect target, whose
paths are opaque and signed per-request so they can't be usefully scoped
further) so `uv python install` can fetch Python distributions. Installing
packages and Python versions works; publishing, or anything else that writes
to these hosts, is blocked by the network policy.
