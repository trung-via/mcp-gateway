# Architecture baseline (draft)

## Principles

- A shared gateway is a coordination point, not a blanket grant to execute on every project.
- The MCP server exposes bounded, versioned, schema-validated tools.
- The server enforces caller identity and per-resource authorization; downstream agents re-check native permissions.
- Read-only tools first; write / system execution later with individual grants and receipts.
- MCP tool responses return to the caller. They are not a general API for delivering a new message into an arbitrary ChatGPT conversation.
- CDP Host may be integrated by explicit contract; it remains a separate project.

## Proposed components

1. MCP endpoint / session transport (decide with source-led testing).
2. Authentication and authorization boundary (identity, audience, scopes, project ACL).
3. Tool registry with JSON Schema and side-effect classification.
4. Adapters for GitHub, Windows, and project services.
5. Durable audit and correlation IDs, with redaction and retention policy.

## Minimum falsifiable experiment

An authorized ChatGPT conversation can discover `gateway_health` and receive a deterministic read-only response. Verify tool identity, request and response schema, authentication behavior, denial behavior, and actual ChatGPT invocation evidence.

## Not yet proven

- The active ChatGPT account's full custom MCP server permissions.
- A verified production endpoint or local MCP server.
- External event -> exact personal Chat A proactive messaging.
- Any permission to control Windows, run shell commands, or write to downstream resources.
