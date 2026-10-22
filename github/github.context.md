# mixin: github

## sandbox

This mixin targets Alpine Linux based workloads running in a Docker Sandbox.

### filesystem

Expect Unix permissions for uid/gid 1001.

### network

The sandbox network policy allows the following:

- api.github.com allows GET and HEAD.
- github.com allows GET and HEAD. POST is also allowed, but only for `/**/git-upload-pack` (git fetch). POST to `/**/git-receive-pack` (git push) is denied.

Note that some hosts and/or HTTP verbs may be denied by the sandbox network policy or by mixins.

### binaries

Before concluding a tool is unavailable because `which` or `find` comes up empty, check whether a mixin's context explains why.
A missing bare binary can be intentional, not absent.
These subsections give definitive information on available binaries and conventions.

#### GitHub CLI

Your sandbox mixin pins gh to 2.x

```shell
gh --version
```

`gh` is available for read-only GitHub inspection.
Use REST GET requests, for example:

```shell
gh api -X GET repos/OWNER/REPO
gh api -X GET repos/OWNER/REPO/pulls/NUMBER
gh api -X GET repos/OWNER/REPO/pulls/NUMBER/files --paginate
```

Do not create, edit, comment on, or merge GitHub resources.
This kit allows POST to GitHub only for Git's `git-upload-pack` fetch endpoint.
Other GitHub writes, including `git push`, are blocked by the network policy.

Some seemingly read-only `gh` commands use GraphQL POST requests and may be blocked.
If that happens, use an equivalent REST GET endpoint.
Adding fields to `gh api` can also change its default method to POST.
Specify `-X GET` when passing query parameters.

GitHub authentication is optional and supplied through the sandbox's proxy-managed credential.
The same credential supports API reads and HTTPS Git fetches.
Never print or save `GH_TOKEN`.
If access fails, report the error rather than changing the network policy.

The GraphQL note matters: gh pr view has used POST /graphql, and gh api switches to POST when fields are supplied unless you set the method.
GitHub CLI API manual, GitHub CLI request example.

#### prek

Your sandbox mixin pins prek to 0.5.7

```shell
prek --version
```
