# Milestone 0 — Foundation

**Job:** Establish the development environment and project skeleton so that every subsequent iteration starts from a clean, runnable baseline.

**Why first:** Nothing else can be built without this. The goal is a running "hello world" end-to-end — not a useful agent, just a working system.

---

## Iterations

### 0.1 — Project scaffold ✅

- FastAPI backend skeleton (health endpoint only)
- Streamlit frontend skeleton (single page, text input, static response)
- Docker Compose wiring (server + portal)
- UV project setup, ruff, pyright
- CLAUDE.md with project conventions

**Acceptance criteria:**
- Given the repo is cloned and Docker is running
- When I run `docker compose up`
- Then the portal is accessible at localhost and displays a text input; submitting any text returns a static placeholder response

### 0.2 — MLflow local setup ✅

- MLflow tracking server in Docker Compose
- Autolog enabled for LLM calls
- A single test LLM call that produces a visible trace in MLflow UI

**Acceptance criteria:**
- Given Docker Compose is running
- When a question is submitted in the portal
- Then a trace appears in the MLflow UI showing the LLM call with inputs, outputs, and token counts

### 0.3 — Azure infrastructure (dev environment) ✅

- Bicep modules: Container Apps environment, AI Foundry, Key Vault
- `deploy-dev.sh` script
- Local RBAC setup script
- GitHub Actions: lint + type check on push

**Acceptance criteria:**
- Given Azure credentials are configured
- When I run `./scripts/deploy-dev.sh`
- Then the dev environment is provisioned and resources are accessible in the Azure portal

---

## Journal

*Milestone 0 was completed before the journaling convention was introduced. See commit history for narrative context.*

---

## Lessons

### 0.1 — Project scaffold

- **Iter 0.1 (.env bootstrap):** Docker Compose `env_file` requires the referenced file to exist even when empty, causing `docker compose up` to fail on a fresh clone. Fixed with `required: false` in compose.yml and a `cp .env.example .env` setup step in CLAUDE.md. *Lesson: always either ship a committed `.env` stub or use `required: false` — don't assume developers will create it manually.*

### 0.2 — MLflow local setup

- **Iter 0.2 (Streamlit ternary):** Using a ternary expression with `st.*` calls causes Streamlit to render the `DeltaGenerator` return value as visible output on the page. *Lesson: always use `if/else` blocks with Streamlit calls — never inline ternary expressions.*

### 0.3 — Azure infrastructure

- **Iter 0.3 (RBAC timing):** Service-to-service role assignments belong in the consuming service's Bicep, not the providing service's. Creating them at provision time requires managed identity IDs that don't exist yet. *Lesson: RBAC follows the consumer — the thing that needs access declares what it needs, not the thing being accessed.*

- **Iter 0.3 (Dev RBAC simplification):** Resource-group-scoped role assignments eliminate the need to track individual resources in dev scripts. Works for most Azure services (Key Vault, Cognitive Services, AI Search). Exception: PostgreSQL uses its own auth system for data plane access. *Lesson: scope dev RBAC broadly, production RBAC narrowly.*

- **Iter 0.3 (CI lock file):** Use `uv sync --frozen` in CI to fail loudly when the lock file is stale. Without `--frozen`, UV silently regenerates, masking dependency drift.

- **Iter 0.3 (Anthropic models via Bicep):** Azure does not support deploying Anthropic models via Bicep/ARM — the required `modelProviderData` property is absent from the schema across all published API versions. Microsoft's own guidance is portal-only deployment. *Lesson: deploy the AI Foundry account via IaC but deploy Anthropic models manually via the portal. Keep model entries commented out in bicepparam with `enabled: false` as documentation of intent.*

- **Iter 0.3 (Anthropic model regions):** Claude models on Azure AI Foundry require specific regions (e.g., `swedencentral`) that may differ from the main resource group location. *Lesson: parameterize foundry instances per-region from the start — the multi-foundry array pattern pays for itself immediately.*

- **Iter 0.3 (script permissions):** Deploy scripts were committed without the executable bit. *Lesson: always `chmod +x` scripts before committing, or add a CI check.*
