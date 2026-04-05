# Milestone Plan

Current status, planned milestones, and backlog for ScholarBot.

---

## Status

| Milestone | Title | Status |
|-----------|-------|--------|
| **0** | Foundation | ✅ Complete |
| **1** | Baseline Agent | 🔨 In progress (1.1 complete) |
| **2** | Eval Harness | 🔲 Not started |
| **3** | Observability | 🔲 Not started |
| **4** | Cloud Deployment | 🔲 Not started |
| **5** | Agentic UI (Phase 1) | 🔲 Not started |
| **6** | Framework Comparison (DSPy) | 🔲 Not started |

---

## Milestone 0 — Foundation

**Job:** Establish the development environment and project skeleton so that every subsequent iteration starts from a clean, runnable baseline.

**Why first:** Nothing else can be built without this. The goal is a running "hello world" end-to-end — not a useful agent, just a working system.

### Iterations

#### 0.1 — Project scaffold
- FastAPI backend skeleton (health endpoint only)
- Streamlit frontend skeleton (single page, text input, static response)
- Docker Compose wiring (server + portal)
- UV project setup, ruff, pyright
- CLAUDE.md with project conventions

**Acceptance criteria:**
- Given the repo is cloned and Docker is running
- When I run `docker compose up`
- Then the portal is accessible at localhost and displays a text input; submitting any text returns a static placeholder response

#### 0.2 — MLflow local setup
- MLflow tracking server in Docker Compose
- Autolog enabled for LLM calls
- A single test LLM call that produces a visible trace in MLflow UI

**Acceptance criteria:**
- Given Docker Compose is running
- When a question is submitted in the portal
- Then a trace appears in the MLflow UI showing the LLM call with inputs, outputs, and token counts

#### 0.3 — Azure infrastructure (dev environment)
- Bicep modules: Container Apps environment, Azure OpenAI, Key Vault
- `deploy-dev.sh` script
- Local RBAC setup script
- GitHub Actions: lint + type check on push

**Acceptance criteria:**
- Given Azure credentials are configured
- When I run `./scripts/deploy-dev.sh`
- Then the dev environment is provisioned and the health endpoint is reachable at the Container Apps URL

---

## Milestone 1 — Baseline Agent

**Job:** Build a working research agent using Claude Agents SDK that can answer complex questions by searching the web, and establish the question-answer dataset needed for grounded error analysis.

**Why second:** This is the core capability. Getting a working agent and understanding its failure modes against real ground truth is the prerequisite for building an objective eval harness in Milestone 2.

### Iterations

#### 1.1 — Single-hop research agent ✅
- Claude Agent SDK agent with built-in WebSearch/WebFetch tools (replaced Tavily)
- Takes a question, searches the web, returns answer + sources
- Connected to Streamlit chat interface
- MLflow tracing via `mlflow.anthropic.autolog()` integration with Agent SDK

**Acceptance criteria:**
- Given the system is running
- When I ask "What is the current population of Tokyo?"
- Then the agent issues a web search, returns an answer with at least one cited source, and the full interaction is visible in MLflow traces

#### 1.2 — Multi-hop research agent
- Agent can decompose complex questions into multiple sequential searches
- Follows up on initial findings to gather deeper evidence
- Synthesizes across multiple sources into a coherent answer

**Acceptance criteria:**
- Given the system is running
- When I ask a question requiring multiple steps (e.g., "How did the Fed's 2022 rate decisions affect mortgage rates in California?")
- Then the agent issues multiple searches, the trace shows sequential tool calls with reasoning between them, and the answer synthesizes findings from multiple sources

#### 1.3 — DeepSearchQA dataset loader
- Download `google/deepsearchqa` from HuggingFace
- Build a dataset loader that samples N examples (configurable, default 25)
- Each sample exposes: question, ground truth answer(s), and domain
- CLI or script to run the agent against the sampled questions and save outputs alongside ground truth for review

**Acceptance criteria:**
- Given the dataset loader is configured with a sample size of 25
- When I run `uv run python -m scholarbot.eval.sample`
- Then it produces a structured output file containing each question, the agent's answer, and the DeepSearchQA ground truth answer — ready for side-by-side review

#### 1.4 — Manual error analysis
- Review the sampled outputs from 1.3: agent answer vs. ground truth, side-by-side
- Use MLflow traces to understand *why* the agent answered the way it did for each failure case
- Categorize observed failure modes (e.g., wrong decomposition, missed evidence, poor synthesis, hallucination)
- Document findings in `docs/iterations/milestone-01.md`
- No fixes in this iteration — observation only

**Acceptance criteria:**
- Given the sampled outputs from 1.3 have been reviewed
- When I open `docs/iterations/milestone-01.md`
- Then it contains a structured analysis of at least 3 distinct failure mode categories, each with example question/answer/ground-truth triplets and a hypothesis about root cause

---

## Milestone 2 — Eval Harness

**Job:** Build an automated evaluation harness that scores the agent against DeepSearchQA at scale so that improvements can be measured objectively and tracked over time.

**Why third:** We have a working agent and understand its failure modes. Now we need objective, repeatable measurement before we start optimizing. The harness is the instrument.

### Iterations

#### 2.1 — LLM-as-judge scorer
- Implement the DeepSearchQA grading prompt as an MLflow `make_judge` scorer
- Scorer takes (question, agent answer, ground truth) and returns a categorical score (Fully Correct / Partially Correct / Fully Incorrect) + F1
- Validate scorer on a small manually-reviewed subset to confirm alignment with human judgment

**Acceptance criteria:**
- Given a sample of (question, agent answer, ground truth) triplets that were manually reviewed in 1.4
- When the scorer runs on those triplets
- Then its categorical scores align with the manual review on at least 80% of cases

#### 2.2 — Full eval pipeline
- End-to-end eval CLI: run agent on N DeepSearchQA examples, score each with the judge, log results to MLflow experiment
- MLflow experiment UI shows score distribution, per-question results, F1 summary
- `docs/iterations/milestone-02.md` captures baseline F1 score and initial observations

**Acceptance criteria:**
- Given the eval pipeline is configured
- When I run `uv run python -m scholarbot.eval --n 100 --experiment baseline-v1`
- Then it runs the agent on 100 questions, scores each, and logs results to the named MLflow experiment with per-question detail and aggregate F1

#### 2.3 — Eval-informed improvement loop (first pass)
- Based on baseline scores and failure mode analysis from 1.4, implement one targeted improvement (e.g., better search query decomposition, improved synthesis prompt)
- Re-run eval, compare experiments in MLflow
- Document what changed, what the score impact was, and what was learned

**Acceptance criteria:**
- Given a targeted improvement has been implemented
- When I compare the two MLflow experiments side-by-side
- Then I can identify which questions improved, which regressed, and the aggregate F1 delta — and `docs/iterations/milestone-02.md` documents the hypothesis, change, and outcome

---

## Milestone 3 — Observability

**Job:** Instrument the system so that every layer of the four-layer framework is visible in MLflow — not just LLM calls, but agent decisions, tool use patterns, and coding agent behavior.

### Iterations

*(To be scoped after Milestone 2 is complete and we understand what observability gaps exist.)*

---

## Milestone 4 — Cloud Deployment

**Job:** Deploy ScholarBot to Azure Container Apps so it is accessible via a public URL and the architecture is production-grade.

### Iterations

*(To be scoped after Milestone 1 baseline is stable.)*

---

## Milestone 5 — Agentic UI (Phase 1)

**Job:** Surface the research process in the UI — intermediate steps, search queries, sources retrieved — so users can follow along with what the agent is doing.

**Note:** This milestone is where the React/Next.js + agentic UI (AG-UI, CopilotKit) decision becomes relevant. Likely requires the React montage sprint to precede this.

### Iterations

*(To be scoped when the time comes.)*

---

## Milestone 6 — Framework Comparison (DSPy)

**Job:** Implement a comparable research agent using DSPy. Run against the same DeepSearchQA harness. Document findings. See FOUNDATIONS.md for the three-phase framework exploration plan.

### Iterations

*(To be scoped after Phase A baseline is well-established and benchmarked.)*

---

## Backlog

| Item | Context | When to revisit |
|------|---------|-----------------|
| LiveDRBench as second benchmark | `microsoft/LiveDRBench`, 100 tasks, May 2025 data, official eval script | After DeepSearchQA harness is stable (Milestone 2 complete) |
| Chat history persistence | In-memory for V1; CosmosDB for production path | Milestone 4 (cloud deployment) |
| Runtime self-optimization (DSPy teleprompters) | Phase C of framework exploration — optimize agent components based on traces and benchmark feedback | After Milestone 6 |
| React frontend + agentic UI patterns | Prerequisite: React montage sprint | Milestone 5 |
| BrowseComp-Plus | High friction (obfuscation, Java, expensive eval) — evaluate feasibility | After LiveDRBench |

---

## Sync Checklist

Run at every iteration boundary:

- [ ] Does PRD still reflect what we're building?
- [ ] Does Architecture reflect the current implementation?
- [ ] Are new backlog items captured?
- [ ] Are lessons from this iteration recorded in the milestone file?
- [ ] Does the remaining plan still make sense given what we learned?
