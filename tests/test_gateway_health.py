"""In-process MCP protocol and read-only handler regression tests."""

import asyncio
import builtins
import os
import subprocess

from mcp import Client

from src.gateway.server import HealthResponse, gateway_health, mcp


EXPECTED = {"service": "mcp-gateway", "version": "0.1.0", "status": "ok"}


def test_direct_health_is_static_and_strict():
    payload = gateway_health()
    assert isinstance(payload, HealthResponse)
    assert payload.model_dump() == EXPECTED
    assert set(payload.model_json_schema()["required"]) == set(EXPECTED)
    assert payload.model_json_schema().get("additionalProperties") is False


def test_no_open_or_subprocess_side_effects(monkeypatch):
    def deny(*_args, **_kwargs):
        raise AssertionError("public health tool may not perform I/O or execute commands")

    monkeypatch.setattr(builtins, "open", deny)
    monkeypatch.setattr(subprocess, "run", deny)
    monkeypatch.setattr(subprocess, "Popen", deny)
    monkeypatch.setattr(os, "system", deny)
    assert gateway_health().model_dump() == EXPECTED


async def exercise_protocol(mode=None):
    kwargs = {"raise_exceptions": True} if mode is None else {"mode": "legacy"}
    async with Client(mcp, **kwargs) as client:
        listing = await client.list_tools()
        assert [tool.name for tool in listing.tools] == ["gateway_health"]
        tool = listing.tools[0]
        assert tool.input_schema["type"] == "object"
        assert tool.input_schema.get("properties", {}) == {}
        assert tool.output_schema["type"] == "object"
        assert set(tool.output_schema["required"]) == set(EXPECTED)
        assert tool.annotations is not None
        assert tool.annotations.read_only_hint is True
        assert tool.annotations.open_world_hint is False
        result = await client.call_tool("gateway_health", {})
        assert not result.is_error
        assert result.structured_content == EXPECTED


def test_modern_mcp_discovery_and_call():
    asyncio.run(exercise_protocol())


def test_legacy_mcp_discovery_and_call():
    asyncio.run(exercise_protocol(mode="legacy"))


async def assert_rejected(name: str, args: dict):
    async with Client(mcp, raise_exceptions=True) as client:
        try:
            result = await client.call_tool(name, args)
        except Exception:
            # MCP protocol may raise for unknown tools or rejected arguments.
            return
        assert result.is_error, "invalid call must not silently return success"


def test_reject_unexpected_argument():
    asyncio.run(assert_rejected("gateway_health", {"unexpected": True}))


def test_reject_unknown_tool():
    asyncio.run(assert_rejected("gateway_missing", {}))
