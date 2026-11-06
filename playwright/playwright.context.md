# mixin: playwright

### binaries

#### chromium

```shell
chromium --version
# Chromium 156.0.8078.79 Alpine Linux
```

#### playwright

```shell
playwright-cli --version
# 0.1.23
```

Do not run `playwright-cli install` to download browsers.
This Alpine image does not run glibc builds, therefore playwright's bundled browswers cannot install.
The browser is Alpine's system Chromium, preconfigured through `PLAYWRIGHT_MCP_*` environment variables.

### skills

#### playwright-cli

Use `playwright-cli` to interact with a headless web browser (chromium).
