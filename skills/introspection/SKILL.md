---
name: introspection
description: Examine the Docker Sandbox Kit (v3) context and configurations.
compatibility: Requires the Agent to run within a Docker Sandbox (sbx).
---

# Introspection

Follow instructions in [context](#context) and [testing](#testing) without output.
Once ready, share output with the user according to the [output](#output) instructions.

## Context

Based on what's loaded in your system context, determine the following about the Docker Sandbox Kit (v3) environment:

- Workload (exactly one)
  - operating system
  - runtime UID/GID
  - commands
  - allowed host + http verbs
  - denied host + http verbs

- Mixins (zero or more)
  - commands
  - allowed host + http verbs
  - denied host + http verbs

- Skills
  - name
  - source
  - path

## Testing

Check each of the determinations above.
Cross-check claims against the structured manifest `/usr/share/sandbox/kit/<harness>.generated/kit.yaml` (read it once — it covers the workload and all mixins together).
Test commands using `< command > --version` or similar version check.
Output the `$PATH` if a command check fails and run `which < command >`.

## Output

Present the report in the following format

    Workload: < workload >

    | property    | claimed             | verified                                        |
    | ----------- | ------------------- | ----------------------------------------------- |
    | UID/GID     | < UID:GID >         | ✅ uid=< uid >(< user >) gid=< uid >(< group >) |
    | < command > | < version >         | ✅ < version >                                  |
    | allow       | < host > (< verb >) | ✅ < host > (< verb >)                          |
    | deny        | < host > (< verb >) | ✅ < host > (< verb >)                          |

    Mixin: < mixin >

    | property    | claimed             | verified                                        |
    | ----------- | ------------------- | ----------------------------------------------- |
    | < command > | < version >         | ✅ < version >                                  |
    | allow       | < host > (< verb >) | ✅ < host > (< verb >)                          |
    | deny        | < host > (< verb >) | ✅ < host > (< verb >)                          |

    Skill: < skill >

    | name        | source     | path     |
    | ----------- | ---------- | -------- |
    | < name >    | < source > | < path > |

Repeat for each mixin, command, host, and verb as needed.
Use ⚠️ instead of ✅ when the claim cannot be verified.
