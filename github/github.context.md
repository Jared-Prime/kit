# GitHub CLI

`gh` is available for read-only GitHub inspection.
Use REST GET requests, for
example:

```shell
gh api -X GET repos/OWNER/REPO
gh api -X GET repos/OWNER/REPO/pulls/NUMBER
gh api -X GET repos/OWNER/REPO/pulls/NUMBER/files --paginate
```

Do not create, edit, comment on, or merge GitHub resources.
This kit's network policy denies POST, PATCH, PUT, and DELETE requests.

Some seemingly read-only `gh` commands use GraphQL POST requests and may be
blocked.
If that happens, use an equivalent REST GET endpoint.
Adding fields to `gh api` can also change its default method to POST.
Specify `-X GET` when passing query parameters.

GitHub authentication is optional and supplied through the sandbox's proxy-managed credential.
Never print or save `GH_TOKEN`.
If access fails, report the error rather than changing the network policy.

The GraphQL note matters: gh pr view has used POST /graphql, and gh api switches to POST when fields are supplied unless you set the method.
GitHub CLI API manual, GitHub CLI request example.
