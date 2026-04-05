# CLAUDE.md

## Project

ScholarBot — a Deep Research agent built with benchmark-driven, self-improving architecture. See `docs/FOUNDATIONS.md` for the conceptual framework and `docs/PRD.md` for product requirements.

## Current Status

**Milestone 0 (Foundation): COMPLETE**
**Milestone 1 (Baseline Agent): IN PROGRESS — Iteration 1.1 complete**

See `docs/iterations/README.md` for the full milestone plan and backlog.

## Meta Directives

*Written by the meta assistant at `~/source/`. Read these at session start — they reflect strategic decisions that affect this project.*

- ScholarBot is the **#1 priority project** in the portfolio. See `~/source/PROJECTS.md` for full priority stack.
- Start with **Claude Agents SDK** for the agent (Phase A). DSPy comes in Phase B.
- Use **Streamlit** for UI in the near term. React/Next.js is a planned montage sprint for later.
- **DeepSearchQA** (`google/deepsearchqa`) is the first benchmark for the eval harness.

## Iteration Loop (follow for every iteration)

Do not skip steps. Do not mark an iteration complete without Validate.

1. **Scope** — define what this iteration delivers, acceptance criteria in Given/When/Then
2. **Align** — present scope to human, confirm before building
3. **Build** — implement the scope
4. **Validate** — human verifies (run it, deploy it, inspect it). If it requires human action, prompt and wait.
5. **Adapt** — fix issues if validation reveals them
6. **Sync** — update ALL of the following:
   - [ ] This file (Current Status section)
   - [ ] `README.md` (Current status + tech stack if changed)
   - [ ] `docs/iterations/README.md` (status table)
   - [ ] Milestone doc (`docs/iterations/milestone-*.md`) — journal entry + lessons
   - [ ] `~/source/PROJECTS.md` (status line for ScholarBot)
   - [ ] PRD and Architecture if they no longer reflect reality
   - [ ] Grep for stale references when a technology or dependency changes

See `docs/STRATEGY.md` for the full methodology.

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
notebooks/          # Jupyter notebooks for SDK exploration
infra/              # Bicep IaC — see infra/README.md
scripts/            # deploy-dev.sh, rbac-dev.sh
docs/               # Living documentation
.github/workflows/  # CI (lint + type check)
```

## Setup

```bash
# First time only
cp .env.example .env   # then fill in secrets as they are added each milestone
uv sync
```

## Commands

```bash
# Install dependencies
uv sync

# Dev (Docker Compose — server + portal + MLflow)
docker compose up --build

# Dev (Docker Compose with hot reload)
docker compose watch

# Lint
uv run ruff check src/ tests/

# Format check
uv run ruff format --check src/ tests/

# Type check
uv run pyright src/

# Jupyter notebooks (SDK exploration)
uv run jupyter lab

# Deploy dev infrastructure (requires az login)
./scripts/deploy-dev.sh

# Grant developer RBAC (one-time after deploy)
./scripts/rbac-dev.sh
```

## Ports

| Service | App | Debugpy |
|---------|-----|---------|
| server_service | 8000 | 5678 |
| portal_service | 8501 | 5679 |
| mlflow_service | 5000 | — |

## Key Conventions

- **Single `pyproject.toml`** at root — all dependencies in one place.
- **`uv sync --frozen`** in Docker builds — lock file is the source of truth.
- **Managed identity** for all Azure services in production. No connection strings or API keys in code.
- **`.env` for local secrets** — never committed. See `.env.example` for required variables.
- **Vertical slices** — each iteration delivers something end-to-end that can be validated in one sitting.
- **Sync checklist** after every iteration — see the Iteration Loop section above.
