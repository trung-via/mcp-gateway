"""Independent HTTP smoke probe. Run while the local server is listening."""

import asyncio

from mcp import Client


async def main() -> None:
    async with Client("http://127.0.0.1:8000/mcp") as client:
        result = await client.list_tools()
        assert [t.name for t in result.tools] == ["gateway_health"]
        call = await client.call_tool("gateway_health", {})
        assert not call.is_error
        assert call.structured_content == {
            "service": "mcp-gateway",
            "version": "0.1.0",
            "status": "ok",
        }
    print("PASS: streamable HTTP gateway_health")


if __name__ == "__main__":
    asyncio.run(main())
