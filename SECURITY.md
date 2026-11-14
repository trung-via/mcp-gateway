# Security policy (bootstrap)

This is a public source repository; it must contain **no credentials or personal data**.

- Never commit API keys, tokens, OAuth refresh tokens, SSH keys, HMAC secrets, cookies, browser profiles, private ChatGPT links, host inventories, or sensitive logs.
- Authenticate callers and check authorization for each project, tool and resource on the server.
- Do not treat human language, tool descriptions, MCP annotations or model-generated metadata as permission.
- For write/execute operations, require explicit grants, idempotency keys, timeout/resource limits, verification receipts, and safe error handling.
- Log minimal request IDs and redacted metadata; never log authorization headers or raw secrets.
- Do not accept arbitrary shell commands or unrestricted file paths from prompts.
- Unknown side effects are reconciled read-only before any retry.

Security reports should be sent privately to the repository maintainer; avoid publishing exploits or secrets in a public Issue.
