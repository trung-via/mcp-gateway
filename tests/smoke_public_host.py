"""Negative Host and Origin checks against a local P2 hosting process.

Run after starting src.gateway.public_server with MCP_PUBLIC_HOSTNAME=localhost
and PORT=18080. The normal MCP positive probe runs independently.
"""

import httpx


def main() -> None:
    url = "http://127.0.0.1:18080/mcp"
    with httpx.Client(timeout=5) as client:
        host = client.get(url, headers={"Host": "unauthorized.example.org"})
        assert host.status_code == 421, (
            f"expected 421 for unapproved Host, got {host.status_code}"
        )

        origin = client.get(
            url,
            headers={
                "Host": "localhost:18080",
                "Origin": "https://malicious.example.org",
            },
        )
        assert origin.status_code == 403, (
            f"expected 403 for unapproved Origin, got {origin.status_code}"
        )
    print("PASS: public entrypoint rejects foreign Host (421) and Origin (403)")


if __name__ == "__main__":
    main()
