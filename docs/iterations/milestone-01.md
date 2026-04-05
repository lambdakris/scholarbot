# Milestone 1 — Baseline Agent: Lessons Log

---

## Iteration 1.1 — Single-hop research agent

**Status:** Complete (validated 2026-04-04)

**Lessons:**

- **Iter 1.1 (Agent SDK is a CLI wrapper):** The Claude Agent SDK (`claude-agent-sdk`) is not a thin API client — it spawns the Claude Code CLI as a subprocess. This means: (a) Node.js must be available at runtime, (b) the CLI is bundled in the Python package so no separate install needed, (c) Azure Foundry configuration is via environment variables (`CLAUDE_CODE_USE_FOUNDRY`, `ANTHROPIC_FOUNDRY_RESOURCE`, `ANTHROPIC_FOUNDRY_API_KEY`), not constructor params. *Lesson: the Agent SDK owns its own LLM connection — don't try to manage it yourself.*

- **Iter 1.1 (Built-in tools replace Tavily):** The Agent SDK provides `WebSearch` and `WebFetch` as built-in tools — no need for Tavily or any external search SDK. These are enabled by name in `ClaudeAgentOptions.allowed_tools`. *Lesson: check what the SDK provides before adding external dependencies.*

- **Iter 1.1 (Docker root user restriction):** The Agent SDK's `bypassPermissions` mode maps to `--dangerously-skip-permissions`, which refuses to run as root. Docker containers default to root. *Lesson: always add a non-root user to Dockerfiles that run the Agent SDK. This is also a general best practice.*

- **Iter 1.1 (MLflow tracing permissions):** MLflow's Agent SDK trace processor (`process_sdk_messages`) tries to create a `.claude/mlflow` log directory in the working directory. If the non-root user doesn't own the workdir, tracing silently fails. The error is swallowed by the autolog's `except` handler. *Lesson: ensure `chown` of the workdir to the app user in the Dockerfile, and test tracing explicitly — silent failures are the worst kind.*

- **Iter 1.1 (Settings simplification):** Switching to the Agent SDK eliminated all Anthropic-related settings from our `Settings` class. The SDK reads its own env vars by convention. *Lesson: when adopting a framework, let it own its configuration rather than wrapping it in your own settings layer.*
