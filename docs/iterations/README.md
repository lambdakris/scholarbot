# Milestone Plan

Current status, planned milestones, and backlog for ScholarBot.

Each active milestone has its own document (`milestone-NN.md`) containing iteration specs, journal entries, and lessons. This file is the dashboard.

---

## Status

| Milestone | Title | Status | Document |
|-----------|-------|--------|----------|
| **0** | Foundation | ✅ Complete | [milestone-00.md](milestone-00.md) |
| **1** | Baseline Agent | 🔨 In progress (1.3 complete) | [milestone-01.md](milestone-01.md) |
| **2** | Eval Harness | 🔲 Not started | — |
| **3** | Observability | 🔲 Not started | — |
| **4** | Cloud Deployment | 🔲 Not started | — |
| **5** | Agentic UI (Phase 1) | 🔲 Not started | — |
| **6** | Framework Comparison (DSPy) | 🔲 Not started | — |

---

## Upcoming Milestones (not yet scoped)

### Milestone 2 — Eval Harness

**Job:** Build an automated evaluation harness that scores the agent against DeepSearchQA at scale so that improvements can be measured objectively and tracked over time.

**Why third:** We have a working agent and understand its failure modes. Now we need objective, repeatable measurement before we start optimizing. The harness is the instrument.

### Milestone 3 — Observability

**Job:** Instrument the system so that every layer of the four-layer framework is visible in MLflow — not just LLM calls, but agent decisions, tool use patterns, and coding agent behavior.

**Known gap:** MLflow's Agent SDK autolog drops ThinkingBlocks, SystemMessages, and per-turn token usage. Plan: monkeypatch locally, then contribute upstream to MLflow.

### Milestone 4 — Cloud Deployment

**Job:** Deploy ScholarBot to Azure Container Apps so it is accessible via a public URL and the architecture is production-grade.

### Milestone 5 — Agentic UI (Phase 1)

**Job:** Surface the research process in the UI — intermediate steps, search queries, sources retrieved — so users can follow along with what the agent is doing.

**Note:** This milestone is where the React/Next.js + agentic UI (AG-UI, CopilotKit) decision becomes relevant. Likely requires the React montage sprint to precede this.

### Milestone 6 — Framework Comparison (DSPy)

**Job:** Implement a comparable research agent using DSPy. Run against the same DeepSearchQA harness. Document findings. See FOUNDATIONS.md for the three-phase framework exploration plan.

---

## Backlog

| Item | Context | When to revisit |
|------|---------|-----------------|
| LiveDRBench as second benchmark | `microsoft/LiveDRBench`, 100 tasks, May 2025 data, official eval script | After DeepSearchQA harness is stable (Milestone 2 complete) |
| Chat history persistence | In-memory for V1; CosmosDB for production path | Milestone 4 (cloud deployment) |
| Runtime self-optimization (DSPy teleprompters) | Phase C of framework exploration — optimize agent components based on traces and benchmark feedback | After Milestone 6 |
| React frontend + agentic UI patterns | Prerequisite: React montage sprint | Milestone 5 |
| MLflow upstream PR: Agent SDK ThinkingBlock tracing | Contribute monkeypatch as proper fix to `mlflow/mlflow` | After Milestone 3 monkeypatch is validated |
| BrowseComp-Plus | High friction (obfuscation, Java, expensive eval) — evaluate feasibility | After LiveDRBench |

---

## Sync Checklist

Run at every iteration boundary:

- [ ] Does PRD still reflect what we're building?
- [ ] Does Architecture reflect the current implementation?
- [ ] Are new backlog items captured?
- [ ] Are lessons from this iteration recorded in the milestone file?
- [ ] Does the remaining plan still make sense given what we learned?
