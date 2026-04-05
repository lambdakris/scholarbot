# Product Requirements Document

ScholarBot — a Deep Research agent for answering complex questions through autonomous multi-hop web research.

---

## Overview

ScholarBot is a web research agent that takes a complex question and autonomously searches the web, follows up on findings, and synthesizes a comprehensive, well-sourced answer. It is designed to be measurably good — its quality is assessed against public Deep Research benchmarks — and to improve over time through an instrumented self-improving loop.

ScholarBot serves two purposes simultaneously:
1. **As a tool:** A useful research assistant for knowledge workers with complex questions.
2. **As a learning artifact:** A vehicle for mastering self-improving AI systems, eval-driven development, MLflow 3.x GenAIOps, and agent orchestration frameworks.

---

## Users

**Primary user:** A knowledge worker, researcher, or developer who needs thorough answers to complex questions — questions that require searching across multiple sources and synthesizing findings, not just a single lookup.

**Secondary user:** The developer (system builder) who uses ScholarBot as a learning and portfolio artifact. This user cares about observability, benchmark scores, and the quality of the underlying system, not just the output.

---

## Jobs to be Done

**Primary jobs:**
- *When I have a complex research question*, I want to get a comprehensive, well-sourced answer *so I can* make informed decisions without spending hours searching manually.
- *When I'm evaluating my research agent*, I want to run it against standard benchmarks *so I can* measure objectively whether my improvements are working.

**Secondary jobs:**
- *When I'm building the system*, I want to observe every LLM call, tool use, and decision *so I can* understand what the agent is doing and where it fails.
- *When I find a failure pattern*, I want to fix it and verify the fix moved the benchmark *so I can* build confidence that improvements are real.

---

## Core Capabilities

### V1 (Baseline Agent + Eval Harness)

**Research:**
- Accept a natural language question via chat interface
- Autonomously decompose the question into search sub-tasks
- Execute multi-hop web searches (via Claude Agent SDK built-in WebSearch) to gather evidence
- Synthesize findings into a comprehensive answer
- Cite sources with links

**Observability:**
- MLflow tracing on all LLM calls, tool uses, and agent steps (autolog)
- Every research session traceable end-to-end in MLflow UI

**Evaluation:**
- Eval harness against DeepSearchQA (`google/deepsearchqa`, 900 examples, live web search)
- LLM-as-judge scoring using MLflow's `make_judge` API
- Benchmark scores tracked as MLflow experiments for comparison across iterations

**UI:**
- Simple chat interface (Streamlit)
- Input: question
- Output: answer + sources
- No streaming or intermediate step visibility in V1 (see Agentic UI below)

### Planned (Post-V1)

**Agentic UI (incremental):**
The UI is designed to evolve toward surfacing the research process — intermediate steps, search queries issued, sources retrieved, reasoning chain. Each step toward this is its own sub-iteration. Likely requires React/Next.js + AG-UI or CopilotKit when this becomes the focus.

**Framework comparison (Phase B):**
Implement a comparable research agent using DSPy. Run against the same DeepSearchQA harness for direct comparison. See FOUNDATIONS.md for the three-phase framework exploration plan.

**Runtime self-optimization (Phase C):**
DSPy teleprompters applied to optimize agent components based on traced runs and benchmark feedback.

**Additional benchmarks:**
- LiveDRBench (`microsoft/LiveDRBench`, 100 tasks, May 2025 data) — add once DeepSearchQA harness is stable.
- BrowseComp-Plus — evaluate feasibility after LiveDRBench.

---

## Non-Functional Requirements

| Requirement | Target | Notes |
|-------------|--------|-------|
| Deployment | Azure Container Apps | Managed identity, no connection strings |
| Local dev | Docker Compose + debugpy | VS Code attach support |
| Package management | UV | Consistent with other projects |
| LLM provider | Azure AI Foundry (Claude) | Via Claude Agent SDK + Foundry env vars |
| Web search | Claude Agent SDK built-in WebSearch | Replaced Tavily — no external search dependency |
| Observability | MLflow 3.x | Tracing, eval, experiment tracking |
| IaC | Bicep | Consistent with VentureBot |
| CI/CD | GitHub Actions | Auto-test on main, manual prod deploy |
| Security | DefaultAzureCredential | All Azure services via managed identity |
| Cost | Optimized for dev/demo | Not enterprise-scale, but architecture is sound |

---

## Success Metrics

| Metric | V1 Target | Notes |
|--------|-----------|-------|
| DeepSearchQA F1 | Baseline established | First run establishes the floor; improvement tracked from there |
| Traces visible in MLflow | 100% of runs | Every research session is fully traced |
| Deployment | Live on Azure Container Apps | Accessible via URL, not just local |
| Eval harness | Runs end-to-end | Full DeepSearchQA eval executes without manual intervention |

---

## Out of Scope (V1)

- Document RAG (over uploaded files) — web search only in V1
- Streaming / real-time intermediate step visibility in UI
- Multi-user support
- Authentication / access control
- React frontend
- DSPy implementation (Phase B)
- Runtime self-optimization (Phase C)
- Additional benchmarks beyond DeepSearchQA

---

## Open Questions

| Question | Status | Notes |
|----------|--------|-------|
| Which Claude model for Azure OpenAI? | Resolved | Claude Haiku 4.5 via Azure AI Foundry in swedencentral |
| DeepSearchQA grading: use Gemini 2.5 Flash (as paper uses) or substitute with Azure OpenAI? | Open | Cost and availability tradeoff |
| CosmosDB for chat history or start with in-memory/SQLite? | Open | SQLite may be simpler for V1; CosmosDB for production path |
| Tavily vs. other search providers? | Resolved | Using Claude Agent SDK built-in WebSearch — no external search provider needed |
