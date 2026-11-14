# ADR-0002: Read-only MCP MVP, authentication boundary and evidence policy

Status: **PROPOSED — reviewed draft; not a production authorization**
Date: 2026-11-14
Owners: MCP Gateway Brain (architecture review); Engineering (implementation only after scoped task)
Supersedes: none; complements [ADR-0001](0001-repository-and-boundaries.md)

## Context and threat boundaries

The public repository is verified to exist on `main`, but **no running MCP server or live ChatGPT tool invocation is verified**. MCP tool calling (ChatGPT -> MCP server -> tool response) and externally triggered wake/return to an exact existing chat are separate problems. The latter remains research, not an MVP prerequisite.

Principals: authenticated end user (when necessary), ChatGPT/MCP client, gateway resource server, downstream project adapter and Windows Host Agent. **A prompt, a client-provided project ID, an opaque session marker, an MCP tool annotation and a GitHub event are not authorization credentials.**

## Proposed architecture for P1/P2

```text
ChatGPT / MCP client
    |
    | HTTPS + MCP Streamable HTTP (/mcp), or local test transport
    v
MCP Gateway
    |-- MCP initialize / tools/list / tools/call
    |-- JSON Schema validation + effect classification
    |-- identity and policy enforcement (per caller, project, tool and resource)
    |-- redacted request/result receipts
    +-- gateway_health [P1: static, anonymous, read-only]
    +-- authenticated/project-scoped tools [later, separately reviewed]
           +-- GitHub adapter [P3]
           +-- Windows Host Agent [P3; independent native policy]
           +-- CDP Host bridge [P4 optional; separate project]
```

Do not introduce a job queue, custom auth server, multi-agent orchestrator or browser automation for the first read-only health proof. A working local MCP endpoint is not evidence that ChatGPT Chat has connected; P2 requires a live tool call witness.

## Tool and identity policy

1. Start with one low-risk `gateway_health` tool: empty input object; deterministic structured response containing service name, version and health state only. No host paths, tokens, account data or sensitive diagnostics. Mark `readOnlyHint=true`; enforce the read-only property in code and tests.
2. For any user-specific data or write access, require real user authentication and authorization. Preferred remote pattern: OAuth 2.1 authorization-code + PKCE; validate signature, issuer, audience/resource, expiry/not-before and scopes **for every protected tool call**. Use a trusted identity provider instead of a home-grown authorization server when practical.
3. Resolve principal and resource ownership from validated credentials and server-side policy, not prompt text, `project_id`, `_meta` or MCP annotations. Reject cross-project/tool/resource access, including through a shared gateway.
4. Write/execute tools do **not** belong to P1/P2. Future proposals require explicit side-effect classes, human confirmation for consequential effects, bounded parameters, server-side grants, native adapter authorization, idempotency and reconciliation of unknown outcomes.
5. Disallow arbitrary PowerShell/shell, unrestricted filesystem paths, credential passthrough and arbitrary URL fetching. No broad admin privilege granted by installing or mentioning a plugin.
6. Make `request_id` and any downstream `job_id` observable, non-secret correlation identifiers. Treat browser/session/origin IDs as routing hints only, not authenticated identity or permission to message a specific ChatGPT conversation.
7. Keep audit output redacted and bounded: tool name, result classification, request ID, timestamp, duration, status and non-sensitive error code. Never log raw access tokens, cookies, private chat URLs or user payloads.

## MVP permissions

| Capability | P1 | P2 | Beyond P2 |
| --- | --- | --- | --- |
| Public non-sensitive `gateway_health` | Allow, read-only | Verify in real Chat | Retain |
| Authenticated account/project status | Not yet implemented | Only if explicitly scoped/tested | OAuth + resource policy |
| GitHub read / Windows status | Not yet implemented | Not required for P2 proof | Separate adapter and least privilege |
| GitHub write / Windows command execution | Deny | Deny | Separate design + authorization |
| External event -> exact Chat A | Not assumed | Not required | Feasibility study and independent acceptance |

## Minimal falsifiable tests

- A local MCP client can initialize, list exactly the expected tool, call `gateway_health` and validate the output schema.
- Invalid input (unknown keys, wrong types), unsupported tool names and malformed requests fail safely with stable error codes.
- Test harness observes **no** file writes, process execution, network calls to project backends or other side effects from `gateway_health`.
- Protected-tool attempts without valid credentials, wrong audience, insufficient scope or wrong project are denied (when such tools exist).
- Tests cover duplicate request IDs, timeouts, cancellation and malformed responses without claiming side effects.
- P2 requires an independently observable tool invocation in **ChatGPT Chat** with exact tool name and response; a successful CLI/Inspector call alone is insufficient.
- GitHub CI evidence and native Windows/ChatGPT evidence remain separate. Do not label queued, accepted or sent messages as completed effects.

## Explicitly unresolved (not permission grants)

- Confirm the target ChatGPT account/surface supports the chosen plugin connection and tool invocation mode.
- Select hosting mode only after testing local transport and deployment needs: remote HTTPS or a supported secure tunnel.
- Pin compatible MCP SDK/protocol versions at implementation time; avoid hardcoding unsupported transport features.
- Choose an identity provider and detailed resource/scope model before any user-specific or write tool.
- Research exact-chat origin/events separately in P4; no assumption that MCP metadata can proactively post into Chat A.

## Source references (reviewed 2026-11-14)

- [OpenAI — Build an MCP server](https://developers.openai.com/plugins/build/mcp-server)
- [OpenAI — Authentication](https://developers.openai.com/plugins/build/auth)
- [OpenAI — Add custom MCP server](https://developers.openai.com/api/docs/guides/custom-mcp-server)
- [OpenAI — MCP servers and Secure MCP Tunnel](https://developers.openai.com/api/docs/guides/tools-connectors-mcp)

## Decision gate

This ADR documents a **reviewed proposal**, not production approval, tested software or a grant to any executor. P1 Engineering can implement the bounded `gateway_health` prototype in an isolated branch with tests; any expansion into personal data, write tools, host execution or proactive chat wake requires a separate explicit decision.
