# Milestone 0 — Foundation: Lessons Log

---

## Iteration 0.1 — Project scaffold

**Status:** Complete

**Lessons:**

- **Iter 0.1 (.env bootstrap):** Docker Compose `env_file` requires the referenced file to exist even when empty, causing `docker compose up` to fail on a fresh clone. Fixed with `required: false` in compose.yml and a `cp .env.example .env` setup step in CLAUDE.md. *Lesson: always either ship a committed `.env` stub or use `required: false` — don't assume developers will create it manually.*
