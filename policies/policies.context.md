### network

The sandbox network policy allows reading resources from the following endpoints:

- api.anthropic.com
- api.github.com
- api.githubcopilot.com
- api.githubcopilot.com
- api.openai.com
- auth.openai.com
- chatgpt.com
- claude.ai
- files.pythonhosted.org
- github.com
- platform.claude.com
- pypi.org
- registry.npmjs.org

The sandbox network policy denies mutating resources on the following endpoints:

- api.github.com
- api.githubcopilot.com
- files.pythonhosted.org
- github.com (POST only to "/**/git-receive-pack", deny all others)
- pypi.org
- registry.npmjs.org

Note that some hosts and/or HTTP verbs may be denied by the sandbox network policy or by mixins.
