# AGENTS.md

## Commands

- Create a host dev environment for tests with Python 3.10+: `python3 -m venv hexstrike-env && source hexstrike-env/bin/activate && python3 -m pip install -r requirements.txt`
- Run the API server locally: `python3 hexstrike_server.py --port 8888`
- Check API health: `curl -fsS http://127.0.0.1:8888/health`
- Run the Docker-hosted MCP stdio bridge: `/usr/local/bin/docker exec -i hexstrike-ai-server python3 /app/hexstrike_mcp.py --server http://127.0.0.1:8888`
- Build and run the local Docker API server: `docker compose up --build`
- Build with the larger Kali toolset when needed: `HEXSTRIKE_TOOLSET=full docker compose build`
- Stop Docker services: `docker compose down`
- Fast syntax check without writing cache into the repo: `PYTHONPYCACHEPREFIX=/private/tmp/hexstrike-pycache python3 -m py_compile hexstrike_server.py hexstrike_mcp.py`
- Run focused unit tests when test dependencies are installed: `PARALLEL=off MIN_COVERAGE=0 ./run_tests.sh unit`

## Active User Decisions

- The working base is `Yenn503/hexstrike-ai` branch `feature/v6.1-refactoring-and-cleanup`.
- The local deployment target is Docker hosting both the Flask API server and the existing `hexstrike_mcp.py` stdio bridge via `docker exec -i`.
- Default Docker settings should be local and conservative: bind to `127.0.0.1`, avoid `privileged: true`, avoid host networking, do not mount the Docker socket, and grant only the named capabilities needed by network tools.
- Do not reintroduce the old upstream monolith or fork-analysis scratch clones.

## Testing and Validation

- Prefer the smallest relevant validation first: syntax check, targeted unit tests, then broader test suites.
- For Docker changes, validate `docker compose config`, then build/run when network and time allow, then check `/health`.
- `/health` reports actual external tool availability; do not assume a tool is installed just because an MCP function exists.
- Add or update tests for changed behavior in `core/`, `api/routes/`, `agents/`, or `tools/` when the change affects runtime behavior.

## Debugging

- Use local evidence first: Flask logs, `/health`, targeted `pytest`, `rg`, and command output from the container.
- If a dependency or Kali package name is uncertain, prefer a small Docker build/log check before changing application code.
- After 2-3 failed attempts on the same blocker, summarize the evidence and ask before switching to online research or a riskier Docker profile.

## Project Structure

- `hexstrike_server.py` starts the Flask API and wires modular blueprints.
- `hexstrike_mcp.py` exposes 64 MCP tools over stdio and forwards calls to the API server.
- `api/routes/` contains Flask blueprints for tool categories, workflows, intelligence, files, health, and telemetry.
- `core/` contains execution, caching, process management, telemetry, visual formatting, and shared infrastructure.
- `agents/` contains bug bounty, CTF, CVE, browser, payload, and decision-engine logic.
- `tools/` contains command-builder abstractions for network, web, recon, and security tools.
- `docker/` contains local container runtime files for the API server and MCP bridge dependencies.
- `docs/` contains developer and setup documentation.
- `tests/` contains unit and integration tests; use targeted paths for quicker feedback.

## Boundaries

- Keep security-tool execution local to authorized targets and user-approved environments.
- Do not add default privileged Docker flags, host networking, or socket mounts without explicit approval.
- Do not commit generated caches, virtualenvs, coverage output, logs, or tool output artifacts.
- Keep comments technical, brief, and in English; explain intent or non-obvious constraints, not line-by-line mechanics.
