# GitHub workflows

The [P1 read-only MCP Windows CI](workflows/p1-mcp-readonly.yml) installs pinned dependencies, checks Python syntax, executes six protocol/schema tests and runs a loopback Streamable HTTP smoke test including `INVALID_PARAMS`.

Verified on merge commit `cabdb994bcb342d4b258adc468eafda2c40c3501`: [GitHub Actions run](https://github.com/trung-via/mcp-gateway/actions/runs/43583364258) **PASS**.

CI demonstrates source/transport tests on ephemeral Windows runners. It does not imply a deployed MCP server or ChatGPT connection.
