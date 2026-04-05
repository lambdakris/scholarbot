# Milestone 1 — Baseline Agent

**Job:** Build a working research agent using Claude Agents SDK that can answer complex questions by searching the web, and establish the question-answer dataset needed for grounded error analysis.

**Why second:** This is the core capability. Getting a working agent and understanding its failure modes against real ground truth is the prerequisite for building an objective eval harness in Milestone 2.

---

## Iterations

### 1.1 — Single-hop research agent ✅

- Claude Agent SDK agent with built-in WebSearch/WebFetch tools (replaced Tavily)
- Takes a question, searches the web, returns answer + sources
- Connected to Streamlit chat interface
- MLflow tracing via `mlflow.anthropic.autolog()` integration with Agent SDK

**Acceptance criteria:**
- Given the system is running
- When I ask "What is the current population of Tokyo?"
- Then the agent issues a web search, returns an answer with at least one cited source, and the full interaction is visible in MLflow traces

### 1.2 — Multi-hop research agent

- Agent can decompose complex questions into multiple sequential searches
- Follows up on initial findings to gather deeper evidence
- Synthesizes across multiple sources into a coherent answer

**Acceptance criteria:**
- Given the system is running
- When I ask a question requiring multiple steps (e.g., "How did the Fed's 2022 rate decisions affect mortgage rates in California?")
- Then the agent issues multiple searches, the trace shows sequential tool calls with reasoning between them, and the answer synthesizes findings from multiple sources

### 1.3 — DeepSearchQA dataset loader

- Download `google/deepsearchqa` from HuggingFace
- Build a dataset loader that samples N examples (configurable, default 25)
- Each sample exposes: question, ground truth answer(s), and domain
- CLI or script to run the agent against the sampled questions and save outputs alongside ground truth for review

**Acceptance criteria:**
- Given the dataset loader is configured with a sample size of 25
- When I run `uv run python -m scholarbot.eval.sample`
- Then it produces a structured output file containing each question, the agent's answer, and the DeepSearchQA ground truth answer — ready for side-by-side review

### 1.4 — Manual error analysis

- Review the sampled outputs from 1.3: agent answer vs. ground truth, side-by-side
- Use MLflow traces to understand *why* the agent answered the way it did for each failure case
- Categorize observed failure modes (e.g., wrong decomposition, missed evidence, poor synthesis, hallucination)
- No fixes in this iteration — observation only

**Acceptance criteria:**
- Given the sampled outputs from 1.3 have been reviewed
- When I open the Error Analysis section of this document
- Then it contains a structured analysis of at least 3 distinct failure mode categories, each with example question/answer/ground-truth triplets and a hypothesis about root cause

---

## Journal

### 1.1 — Single-hop research agent (2026-04-04)

The original plan called for Tavily as the web search provider. During scoping, we discovered that the Claude Agent SDK provides built-in `WebSearch` and `WebFetch` tools, eliminating the need for an external search dependency entirely. This was the first of several surprises about how the Agent SDK works.

The biggest conceptual shift: the Agent SDK is not a thin API client like the `anthropic` Python package. It's a wrapper around the Claude Code CLI, spawned as a subprocess. This has real implications — Node.js is a runtime dependency, configuration happens through environment variables (not constructor params), and the subprocess architecture means MLflow's autolog needs to intercept at the SDK client level in our process, not at the API call level.

Docker integration hit two issues. First, the SDK's `bypassPermissions` mode (necessary for a server that needs to run tools without human approval) refuses to run as root — a sensible security restriction that forced us to add a non-root user to the Dockerfile. Second, MLflow's trace processor tries to create a `.claude/mlflow` directory in the working directory, which failed silently when the non-root user lacked write permissions. The fix was `chown` of the workdir, but the silent failure was the real lesson — we only found it by calling `process_sdk_messages` directly and watching it throw.

Authentication against Azure AI Foundry required getting the right API key and env var names (`CLAUDE_CODE_USE_FOUNDRY=1`, `ANTHROPIC_FOUNDRY_RESOURCE`, `ANTHROPIC_FOUNDRY_API_KEY`). The SDK reads these by convention — no manual client construction needed.

End result: a working research agent that takes a question, searches the web, and returns a sourced answer, with full traces visible in MLflow. The code is remarkably simple — the complexity is in the configuration and infrastructure, not the application logic.

---

## Lessons

### 1.1 — Single-hop research agent

- **Iter 1.1 (Agent SDK is a CLI wrapper):** The Claude Agent SDK (`claude-agent-sdk`) is not a thin API client — it spawns the Claude Code CLI as a subprocess. This means: (a) Node.js must be available at runtime, (b) the CLI is bundled in the Python package so no separate install needed, (c) Azure Foundry configuration is via environment variables (`CLAUDE_CODE_USE_FOUNDRY`, `ANTHROPIC_FOUNDRY_RESOURCE`, `ANTHROPIC_FOUNDRY_API_KEY`), not constructor params. *Lesson: the Agent SDK owns its own LLM connection — don't try to manage it yourself.*

- **Iter 1.1 (Built-in tools replace Tavily):** The Agent SDK provides `WebSearch` and `WebFetch` as built-in tools — no need for Tavily or any external search SDK. These are enabled by name in `ClaudeAgentOptions.allowed_tools`. *Lesson: check what the SDK provides before adding external dependencies.*

- **Iter 1.1 (Docker root user restriction):** The Agent SDK's `bypassPermissions` mode maps to `--dangerously-skip-permissions`, which refuses to run as root. Docker containers default to root. *Lesson: always add a non-root user to Dockerfiles that run the Agent SDK. This is also a general best practice.*

- **Iter 1.1 (MLflow tracing permissions):** MLflow's Agent SDK trace processor (`process_sdk_messages`) tries to create a `.claude/mlflow` log directory in the working directory. If the non-root user doesn't own the workdir, tracing silently fails. The error is swallowed by the autolog's `except` handler. *Lesson: ensure `chown` of the workdir to the app user in the Dockerfile, and test tracing explicitly — silent failures are the worst kind.*

- **Iter 1.1 (Settings simplification):** Switching to the Agent SDK eliminated all Anthropic-related settings from our `Settings` class. The SDK reads its own env vars by convention. *Lesson: when adopting a framework, let it own its configuration rather than wrapping it in your own settings layer.*
