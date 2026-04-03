# Milestone 0 — Foundation: Lessons Log

---

## Iteration 0.3 — Azure infrastructure

**Status:** Complete

**Lessons:**

- **Iter 0.3 (RBAC timing):** Service-to-service role assignments belong in the consuming service's Bicep, not the providing service's. Creating them at provision time requires managed identity IDs that don't exist yet. *Lesson: RBAC follows the consumer — the thing that needs access declares what it needs, not the thing being accessed.*

- **Iter 0.3 (Dev RBAC simplification):** Resource-group-scoped role assignments eliminate the need to track individual resources in dev scripts. Works for most Azure services (Key Vault, Cognitive Services, AI Search). Exception: PostgreSQL uses its own auth system for data plane access. *Lesson: scope dev RBAC broadly, production RBAC narrowly.*

- **Iter 0.3 (CI lock file):** Use `uv sync --frozen` in CI to fail loudly when the lock file is stale. Without `--frozen`, UV silently regenerates, masking dependency drift.

---

## Iteration 0.2 — MLflow local setup

**Status:** Complete

**Lessons:**

- **Iter 0.2 (Streamlit ternary):** Using a ternary expression with `st.*` calls causes Streamlit to render the `DeltaGenerator` return value as visible output on the page. *Lesson: always use `if/else` blocks with Streamlit calls — never inline ternary expressions.*

---

## Iteration 0.1 — Project scaffold

**Status:** Complete

**Lessons:**

- **Iter 0.1 (.env bootstrap):** Docker Compose `env_file` requires the referenced file to exist even when empty, causing `docker compose up` to fail on a fresh clone. Fixed with `required: false` in compose.yml and a `cp .env.example .env` setup step in CLAUDE.md. *Lesson: always either ship a committed `.env` stub or use `required: false` — don't assume developers will create it manually.*
