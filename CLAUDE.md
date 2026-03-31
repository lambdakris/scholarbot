# CLAUDE.md

## Project

ScholarBot — a Deep Research agent built with benchmark-driven, self-improving architecture. See `docs/FOUNDATIONS.md` for the conceptual framework and `docs/PRD.md` for product requirements.

## Current Status

**Milestone 0 (Foundation): IN PROGRESS — on Iteration 0.1**

See `docs/iterations/README.md` for the full milestone plan and backlog.

## Documentation

Read these before making significant changes:

- **[docs/FOUNDATIONS.md](docs/FOUNDATIONS.md)** — Four-layer optimization framework, DSPy vs Claude Agents SDK thesis, benchmark strategy. The north star.
- **[docs/STRATEGY.md](docs/STRATEGY.md)** — Development methodology. Milestone/Iteration structure, Iteration Loop (Scope → Align → Build → Validate → Adapt → Sync).
- **[docs/PRD.md](docs/PRD.md)** — What ScholarBot does, JTBD, capabilities, success metrics.
- **[docs/iterations/README.md](docs/iterations/README.md)** — Milestone plan, current status, backlog, sync checklist.

## Structure

```
src/server/         # FastAPI backend
src/portal/         # Streamlit frontend
tests/              # Integration tests
infra/              # Bicep IaC (added in Milestone 0.3)
docs/               # Living documentation
scripts/            # Developer scripts (added in Milestone 0.3)
```

## Commands

```bash
# Install dependencies
uv sync

# Dev (Docker Compose — server + portal)
docker compose up --build

# Dev (Docker Compose with hot reload)
docker compose watch

# Lint
uv run ruff check src/ tests/

# Format check
uv run ruff format --check src/ tests/

# Type check
uv run pyright src/
```

## Ports

| Service | App | Debugpy |
|---------|-----|---------|
| server_service | 8000 | 5678 |
| portal_service | 8501 | 5679 |
| mlflow_service | 5000 | — |

MLflow added in Milestone 0.2.

## Key Conventions

- **Single `pyproject.toml`** at root — all dependencies in one place.
- **`uv sync --frozen`** in Docker builds — lock file is the source of truth.
- **Managed identity** for all Azure services (added in Milestone 0.3). No connection strings or API keys in code.
- **`.env` for local secrets** — never committed. See `.env.example` for required variables.
- **Vertical slices** — each iteration delivers something end-to-end that can be validated in one sitting.
- **Sync checklist** after every iteration — see `docs/iterations/README.md`.
