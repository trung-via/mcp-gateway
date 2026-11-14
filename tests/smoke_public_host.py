"""Negative Host and Origin checks against a local P2 hosting process.

Run after starting src.gateway.public_server with MCP_PUBLIC_HOSTNAME=localhost
and PORT=18080. Uses Python stdlib only: no extra test dependency.
"""

from urllib.error import HTTPError
from urllib.request import Request, urlopen


def status_for(url: str, headers: dict[str, str]) -> int:
    request = Request(url, headers=headers, method="GET")
    try:
        with urlopen(request, timeout=5) as response:
            return response.status
    except HTTPError as error:
        return error.code


def main() -> None:
    url = "http://127.0.0.1:18080/mcp"
    host_status = status_for(url, {"Host": "unauthorized.example.org"})
    assert host_status == 421, (
        f"expected 421 for unapproved Host, got {host_status}"
    )

    origin_status = status_for(
        url,
        {
            "Host": "localhost:18080",
            "Origin": "https://malicious.example.org",
        },
    )
    assert origin_status == 403, (
        f"expected 403 for unapproved Origin, got {origin_status}"
    )
    print("PASS: public entrypoint rejects foreign Host (421) and Origin (403)")


if __name__ == "__main__":
    main()
