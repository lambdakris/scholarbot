# Foundations

The conceptual underpinning of ScholarBot — what we're building, why, and the framework that governs how we build it. Read this before the PRD or Architecture. It is the north star that those documents serve.

---

## What ScholarBot Is

ScholarBot is a Deep Research agent — an AI system that can autonomously perform multi-hop research over the web and/or a document corpus to answer complex questions. It is generic by design: it solves a well-studied, well-benchmarked problem domain, which means its quality can be measured objectively rather than subjectively.

This is a deliberate choice. ScholarBot is not primarily a product — it is a **learning vehicle and portfolio artifact** built to master a specific set of AI engineering capabilities:

1. Building self-improving AI systems driven by objective benchmarks
2. Instrumenting and operating an AI system with a full GenAIOps platform (MLflow 3.x)
3. Developing hands-on, comparative understanding of DSPy and Claude Agents SDK as agent orchestration frameworks
4. Demonstrating benchmark-driven, eval-informed development methodology

These are the skills that define a strong AI engineer in 2026. ScholarBot is the vehicle for developing and demonstrating them.

---

## The Four-Layer Optimization Framework

Modern AI system development involves multiple nested optimization loops. Understanding where each sits — and what tools govern each — is the core architectural insight behind ScholarBot.

```
┌─────────────────────────────────────────────────────────────────┐
│  Layer 0: Human Verification                                    │
│  Is this artifact what I intended?                              │
│  Tool: STRATEGY.md (Scope → Check → Build → Verify → Adapt → Sync) │
├─────────────────────────────────────────────────────────────────┤
│  Layer 1: Eval-Informed Development                             │
│  Does the system perform well at its task?                      │
│  Tool: MLflow 3.x + benchmarks (BrowseComp, DeepSearchQA, etc.) │
├─────────────────────────────────────────────────────────────────┤
│  Layer 2: Runtime Self-Optimization                             │
│  Can the system improve itself in production?                   │
│  Tool: DSPy teleprompters / MLflow feedback loops              │
├─────────────────────────────────────────────────────────────────┤
│  Layer 3: Coding Agent Optimization                             │
│  Is the agent building this system effective on this project?   │
│  Tool: MLflow tracing of Claude Code + CLAUDE.md conventions   │
└─────────────────────────────────────────────────────────────────┘
```

### Layer 0 — Human Verification
The development process loop. At each sub-iteration boundary, the human developer verifies that the artifact (code, UI, design doc) matches intent. If it doesn't, they steer the coding agent to adapt. This is a human cognitive act — no instrumentation platform replaces it.

**Governed by:** STRATEGY.md's Iteration Loop.

### Layer 1 — Eval-Informed Development
Public benchmarks (BrowseComp-Plus, DeepSearchQA, DeepResearch Bench II) provide objective measures of ScholarBot's research quality. These scores are tracked in MLflow experiments and used to inform development decisions: what to build next, where performance gaps are, whether an optimization actually helped.

**Note:** Benchmarks are the signal for AI/agentic sub-iterations. Platform, infrastructure, and UX sub-iterations have their own acceptance criteria and are not expected to move benchmark scores.

**Governed by:** MLflow 3.x evaluation framework + benchmark harness.

### Layer 2 — Runtime Self-Optimization
ScholarBot is designed so that it can improve itself over time based on usage data and feedback. DSPy's optimization capabilities (teleprompters, few-shot compilation) operate here — taking traces and feedback signals and producing better prompts and demonstrations without manual engineering.

**Governed by:** DSPy / MLflow self-improving loop (trace → analyze → score → fix → verify).

### Layer 3 — Coding Agent Optimization
The coding agent (Claude Code) building ScholarBot can itself be observed and optimized for this project. MLflow traces Claude Code's behavior; project-specific CLAUDE.md conventions encode domain knowledge; MLflow Skills provide project-specific capabilities to the agent.

**Governed by:** MLflow autolog for Claude Code + CLAUDE.md.

### Key Insight
Layers 1–3 are all within MLflow's instrumentation scope simultaneously. Layer 0 is not — it is the human process layer. Conflating them leads to misallocating the right tools to the wrong problems.

---

## Framework Exploration: DSPy and Claude Agents SDK

A secondary goal of ScholarBot is to develop deep, hands-on understanding of both DSPy and the Claude Agents SDK as agent orchestration frameworks — not from documentation, but from building real systems with each.

Whether these frameworks are competing, complementary, or both is treated as an **open question** to be answered through experimentation, not assumed upfront. The approach is incremental:

1. **Phase A:** Build ScholarBot's core agentic capabilities using Claude Agents SDK. Establish a working baseline and benchmark scores.
2. **Phase B:** Implement a comparable agentic system using DSPy. Measure against the same benchmarks.
3. **Phase C:** Explore combining the two — using DSPy to optimize components inside a Claude Agents SDK agent. Assess whether the combination yields something neither framework achieves alone.

The eval harness is designed to be framework-agnostic from day one so that results across phases are genuinely comparable.

---

## Benchmark Strategy

For AI/agentic sub-iterations, ScholarBot's quality is measured against public Deep Research benchmarks. These are not just evaluation tools — they are the product loop's feedback signal for that class of work. When an agentic sub-iteration completes, we ask: did benchmark scores move, and do we understand why?

**Target benchmarks:**
- **BrowseComp-Plus** — multi-hop web research with verifiable answers
- **DeepSearchQA** — complex question answering requiring synthesis across sources
- **DeepResearch Bench II** — comprehensive research quality evaluation

**Reference collection:** [pinboard.in/u:lambdakris/t:%252Bdeepsearch](https://pinboard.in/u:lambdakris/t:%252Bdeepsearch)

**Phasing:** Start with one benchmark to establish the eval harness. Add additional benchmarks as the system matures. Do not add a benchmark without first understanding what it measures and how it differs from existing ones.

---

## Design Philosophy

**Benchmark-driven development (for AI features).** AI/agentic features are justified by their expected impact on benchmark scores. If we can't hypothesize how a change will affect the eval, we should question whether to build it.

**Evals as first-class citizens.** The evaluation harness is built early — not bolted on later. Every agentic sub-iteration runs evals to verify direction.

**Incremental framework comparison.** DSPy and Claude Agents SDK are explored sequentially and then in combination. We let the evidence guide conclusions rather than assuming the answer.

**Methodology over velocity.** The point of ScholarBot is not to ship fast — it is to build correctly and learn deeply. A well-documented, well-instrumented system that scores 60% on BrowseComp is more valuable than an undocumented one that scores 70%.

**Production-grade skeleton.** Cloud-deployed (Azure Container Apps), containerized, managed identity, CI/CD. Cost-optimized but architecturally sound.
