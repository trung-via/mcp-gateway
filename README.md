# MCP Gateway

An independent, public, evidence-driven project for safely connecting ChatGPT to authorized tools across multiple projects using the Model Context Protocol (MCP).

> Status: **planning / bootstrap only**. This repository does not yet provide a working MCP server, Windows agent, ChatGPT connection, or chat wake-up mechanism.

## Goals

1. Provide a small MCP-compatible gateway with discoverable, documented tools.
2. Separate authentication, authorization, and project-specific adapters.
3. Verify tool calls originating from a ChatGPT conversation without assuming external events can proactively message that conversation.
4. Connect Windows and GitHub only after a read-only prototype is tested.
5. Keep CDP Host and AI Commerce independent; integrate only through explicit bounded contracts.

## Architecture

See [architecture overview](docs/architecture/overview.md), [ADR-0001](docs/adr/0001-repository-and-boundaries.md), [roadmap](docs/roadmap.md), and [worktree](docs/worktree.md).

```text
ChatGPT / other MCP client
        |
        v
   MCP Gateway
   | authn/authz | tool registry | audit |
        |
        +-- Windows Host adapter (planned)
        +-- GitHub adapter (planned)
        +-- Project adapters (planned)
```

## Security baseline

Public source does not mean public execution permissions. Never commit secrets, user data, browser cookies, access tokens, private conversation URLs, or real host paths. Tool annotations are descriptive, not authorization controls. See [SECURITY.md](SECURITY.md).

## Roadmap

- P0: bootstrap canonical source, ADRs, security and tool contracts
- P1: implement a read-only MCP prototype with tests
- P2: verify discovery and tool execution in ChatGPT Chat
- P3: integrate independently authorized Windows and GitHub adapters
- P4: research external events, origin correlation, and optional CDP bridge
- P5: reliability, release, and operations

## Relationship to ChatGPT plugin

The `MCP Gateway Brain` plugin is a **planning and review** interface, not evidence that a gateway server is deployed. Code and test evidence become authoritative only when committed and verified in this repository.

## License

No license has been selected. Public visibility alone does **not** grant third parties an open-source license; choose and add a LICENSE after deciding how the source should be reused.
