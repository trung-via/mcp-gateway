# Tool contract: `gateway_health` v1

Status: **ACCEPTED FOR READ-ONLY SOURCE/TEST MVP** (2026-11-14). Not deployed.
Owner: MCP Gateway core. Implementation: [Issue #1](https://github.com/trung-via/mcp-gateway/issues/1).
Decisions: [ADR-0002](../../docs/adr/0002-mcp-mvp-security-and-evidence.md).

## User goal

Allow an MCP client, and eventually ChatGPT Chat, to verify that the Gateway MCP endpoint has registered a responsive tool. **This tool does not inspect Windows, GitHub, the current user or any project's private state.**

## Tool metadata

| Field | Value |
| --- | --- |
| Stable name | `gateway_health` |
| Human title | MCP Gateway health |
| Trigger | Check whether this read-only Gateway tool responds |
| Effect | `READ` with no external downstream dependency |
| Authentication | Anonymous only for this single public, non-sensitive health response |
| Scope | No project, user, host or resource scope required |
| `readOnlyHint` | `true` |
| `openWorldHint` | `false` |
| `destructiveHint` | `false` |
| Idempotency | Safe to repeat; no job or write effect |
| Retry | Ordinary transport retry is safe because tool has no effect |
| Output | Deterministic: service/version/status only |
| Logging | Minimal errors/health aggregate; never raw credentials or Chat IDs |

## Input schema

Zero parameters. The call argument is the empty JSON object `{}`. The server rejects unknown arguments, non-object input and unsupported tool names.

```json
{
  "type": "object",
  "properties": {},
  "additionalProperties": false
}
```

## Output schema

```json
{
  "type": "object",
  "additionalProperties": false,
  "required": ["service", "version", "status"],
  "properties": {
    "service": {"type": "string", "const": "mcp-gateway"},
    "version": {"type": "string", "const": "0.1.0"},
    "status": {"type": "string", "const": "ok"}
  }
}
```

Example `structuredContent`:

```json
{"service":"mcp-gateway","version":"0.1.0","status":"ok"}
```

The server MUST NOT return hostname, PID, OS information, internal addresses, environment variables, account IDs, project names, Chat A IDs, credentials, file contents or network state.

## MCP transport and SDK

- Python SDK `mcp==2.3.0` (research pin for P1; update requires review).
- MCP v2 server supports modern protocol 2026-07-28 (`server/discover`) and legacy compatible 2025-era (`initialize`) clients. Do not demand `initialize` from a modern client.
- Local development Streamable HTTP bind to `127.0.0.1`, endpoint `/mcp`. No public endpoint or customer auth is implied.

## Acceptance tests

1. Discover exactly the intended `gateway_health` tool and metadata.
2. Check generated input/output schemas against this document.
3. Call with `{}` and get the exact structured object above; no `isError`.
4. Call with `{"unexpected":true}` and verify a bounded failure; ensure no success is reported.
5. Unknown tool name returns a bounded failure.
6. Test SDK v2 modern client and, if supported, explicitly exercise legacy protocol initialization; record actual version negotiated.
7. No file/process/backend network effects in `gateway_health` handler.
8. CI on Windows produces a commit-pinned log with test outcomes. A CI PASS is not P2 live ChatGPT proof.

## Out of scope

GitHub or Windows status, write/execute tools, private project data, auth onboarding, Chat wake, CDP bridge, metrics and monitoring are separate contracts.
