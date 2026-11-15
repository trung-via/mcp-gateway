# Private MCP Gateway HostOps — installation source template

**Template only. NOT deployed.** The intended repository `trung-via/mcp-gateway-hostops-private` must be **private** and separately controlled by the owner. Do not run this workflow in public `trung-via/mcp-gateway` or `ai-commerce`.

## Explicit deployment gates
1. Verify the new private repo is private, the GitHub connector is authorized for that repo and only the owner can create Issues or change `main`/workflows. Reject untrusted collaborators, PRs/forks, issue transfers and reused runner identities.
2. Commit this template as `.github/workflows/mcp-p2-provider-readonly.yml` in the private repo after review. Copy the reviewed script `scripts/hostops/p2-ipv6-provider-controls-readonly.ps1` from public PR #10 exactly, with LF bytes; add `.gitattributes` entry `*.ps1 text eol=lf` to preserve the pinned Git blob `1172099c35eccb56d694d9a3c2f4fa3a145aced5`. Do not modify source without a new review and SHA update.
3. Enroll a **new**, dedicated non-admin Windows PowerShell7 runner under the private repo only, with label `mcp-gateway-hostops-private`, no AI Commerce shared workdir or credentials. Never copy or surface enrollment token.
4. Only after private repo, runner and operation are independently verified, Brain may create **one private Issue** with exact title `MCP_P2_IPV6_PROVIDER_CONTROL_READONLY_V1` and exact body `{}`. The first job on GitHub-hosted Windows verifies owner, repo, title/body, newness and single attempt; only an admitted request can queue self-hosted work.
5. The private job reads the **fixed** source, verifies its blob, executes no arguments, validates enum-only results and comments sanitized receipt **to the same private Issue**. Brain separately inspects this receipt via authorized GitHub connector and may summarize counts in public Issue #9.
6. Native proof requires private run/job URL, actual runner identity evidence, the receipt correlation, exact verified blob and independent readback. Workflow source CI alone is not native proof.

## No authority from template alone
Creating the private repo or copying this template does not authorize arbitrary Windows actions, admin, firewall changes, live listeners, ACME, DNS, CDP 9444, router changes, general command execution, raw IP/hostname disclosure or fourth CA attempt. If any gate cannot be verified, stop at `BLOCKED_NO_PRIVATE_HOSTOPS_NATIVE_ROUTE`.

## Critical anti-replay note
The sample denies GitHub job reruns (`GITHUB_RUN_ATTEMPT != 1`) and old requests. Verify the actual GitHub sender identity used by the approved GitHub connector before enabling the private runner. No fallback to `github.actor` from the Issue body, and never remove owner check to make an event pass.

## Known not-yet-proven assumptions
- Whether GitHub connector can read/write the newly created private repo.
- Whether `trung-via` is the actual sender login for connector-created Issues.
- Whether a distinct Windows runner can be enrolled non-interactively using the currently granted tools.
- Whether the private repo can enforce the required main/Actions restrictions.

These are stop conditions, not reasons to borrow AI Commerce HostOps permissions or ask Human to run diagnostics.
