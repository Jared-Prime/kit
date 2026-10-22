## Philosophy

Given that the project aims to provide a safe working environment for agent-enhanced software development, we want to ensure that the project uses safe dependencies, controlled network policies, and very-focused agent attention.

[Trivy](https://github.com/marketplace/actions/aqua-security-trivy) scans check releases for potential vulnerabilities, while [Renovate](https://github.com/marketplace/actions/renovate-bot-github-action) automatically upgrades dependencies to new releases.
Any gaps in either automated checks or upgrades should be considered security bugs and reported.

Sandbox network policies intend to close unnecessary access from the sandbox to the local or public network.
Any unintended network access should be considered a security bug and reported.

Agent context and behavior poses a new class of security risk that's difficult to anticipate.
Where possible, tool use should be gated behind User authorization or denied outright.
Commands run in the shell by the Agent should not work around sandbox limitations.
In practice, workarounds by the Agent may be difficult to detect; this is [an open issue](https://github.com/Jared-Prime/kit/issues/90) for improvement.
Any unintended tool use or commands should be considered security bugs and reported.

## Reporting

Security reports should be given similarly to bug reports, except with special sensitivity to real-world users' safety.
Developers and security researchers should open a GitHub Issue; note there's *no bug bounty* offered.
LLM agents should stop, not attempt a workaround, and describe the flaw to the user.

Provide a report with the following information

* any CVE references
* type of issue (e.g. sandbox escape)
* full path of source files
* tag, branch, or commit
* configuration required for reproduction
* step-by-step instructions for reproduction
* proof-of-concept or exploit code
* impact or risk assessment
