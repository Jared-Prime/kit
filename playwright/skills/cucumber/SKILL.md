# cucumber

## Task

Read edited `.feature` files and produce working playwright tests.
Report what the UI needs to pass the test scenarios.
Provide test support only; never edit the site.

## Scope

The agent may edit:

- `tests/steps/**`
- `tests/support/**`
- `cucumber.json`

The agent must not edit:

- `src/**`

All site changes are a separate responsibility from this task.

## Steps

### Detect Changes

```shell
git status --short tests/features
git diff HEAD -- tests/features
```

### Read the Changes

Use the harness built-in read tool to see what exists [in-scope](#scope).

### Implement Missing Steps

Get the undefined steps by running

```shell
pnpm test:features
```

then write step definitions in `tests/features/<feature>.steps.ts`.
See [conventions](#conventions) for preferred styles.

### Classify Failures

If `pnpm test:features` fails before any scenario executes, then report an environment problem and stop.
Do not fix environment problems by changing scenarios or hiding failures.

If a bad locator, wrong assertion, or step wording mismatch occurs, fix within test support [scope](#scope) and re-run.

If the failure indicates a likely gap in the site code, record it for the [report](#failure-report).
Never touch `src/`.

## Failure Report

```markdown
| Scenario   | Step   | Outcome             | File               |
| ---------- | ------ | ------------------- | ------------------ |
| <scenario> | <step> | <pass or fail>      | < file under src > |
```

If there's no failures, do not print a table.

## Conventions

- use TypeScript erasable syntax only
  - expect node to strip types
  - use `import type`
  - avoid enums or parameter properties
- assert on the feature text and nothing more
  - do not use values the scenario did not state
- rename or move steps only when the feature wording changes
