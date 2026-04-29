# Docker and MCP Bridge

This branch keeps HexStrike's two-process design inside one local container:

- Docker hosts the Flask API server from `hexstrike_server.py` on `127.0.0.1:8888`.
- MCP clients run `hexstrike_mcp.py` over stdio through `docker exec -i`, pointing it at that API server.

## Build and run

```bash
docker compose up --build
```

Use the smaller default `core` toolset for normal local work. It installs essential tools strictly and common tools on a best-effort basis. To attempt the heavier Kali toolset:

```bash
HEXSTRIKE_TOOLSET=full docker compose build
docker compose up
```

Use `HEXSTRIKE_TOOLSET=none` when you only need to test the Flask server and MCP bridge without external security tools.

## Check the server

```bash
curl -fsS http://127.0.0.1:8888/health
```

The `/health` response is the source of truth for which external binaries are available in the image.

The default compose profile binds only to `127.0.0.1`, avoids host networking, avoids privileged mode, and does not mount the Docker socket. It grants `NET_ADMIN`, `NET_BIND_SERVICE`, and `NET_RAW` because Kali tools such as `nmap` use file capabilities that require those at runtime.

## MCP client config

Start the Docker service first, then configure your MCP client to run the bridge inside the running container:

```json
{
  "mcpServers": {
    "hexstrike-ai": {
      "command": "/usr/local/bin/docker",
      "args": [
        "exec",
        "-i",
        "hexstrike-ai-server",
        "python3",
        "/app/hexstrike_mcp.py",
        "--server",
        "http://127.0.0.1:8888"
      ],
      "description": "HexStrike AI v6.1 Docker-hosted stdio MCP bridge",
      "timeout": 300,
      "disabled": false
    }
  }
}
```

If you prefer running the MCP bridge directly on the host, use Python 3.10+ and install `mcp` plus `requests` in a local virtual environment.

## Stop

```bash
docker compose down
```
