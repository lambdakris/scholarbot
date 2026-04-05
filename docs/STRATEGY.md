# Project Strategy

A lightweight, repeatable process for building software iteratively with AI assistance. Designed to handle uncertainty and course corrections without losing coherence.

---

## Terminology

This document uses a two-level hierarchy for organizing work:

- **Milestone** — a thematic grouping of related work (e.g., Milestone 2: Document Pipeline). Each milestone has a job-to-be-done and contains one or more iterations.
- **Iteration** — the smallest unit of deliverable work (e.g., 2.1: Document CRUD). Each iteration is scoped to a vertical slice that can be built and validated in one sitting.

The **Product Loop** operates at the milestone level — cycling through discovery, specification, planning, and execution as understanding evolves. The **Iteration Loop** operates at the iteration level — the concrete build-and-validate rhythm for each piece of work.

---

## Core Principles

1. **Specs are living documents.** They describe the current understanding, not a frozen contract. When reality diverges from spec, update the spec.

2. **Vertical slices over horizontal layers.** Each iteration should deliver a thin but complete slice of functionality — from UI to data — that a human can use and evaluate. Avoid iterations that are "all infrastructure" or "all backend" with nothing to validate end-to-end unless there is a specific reason — such as bootstrapping.

3. **Outside-in development.** Start from the user-facing surface and work inward. Define what the user sees and does first (UI, API contract, experience flow), then build the internals to support it. This ensures the experience drives the implementation rather than the reverse, and surfaces UX issues before deep technical investment.

4. **Discovery is continuous.** The initial discovery pass reduces uncertainty, but every iteration may reveal new things and require adaptation. The process must expect and accommodate this rather than treating the initial plan as fixed.

5. **Small iterations, tight feedback loops.** Each iteration should be small enough that: (a) a human can validate it in one sitting, (b) the cost of changing direction is low, and (c) the scope is unambiguous.

6. **Keep everything in sync.** When changes are introduced, update the specs. When specs change, update the plan. When the plan changes, update the iteration scope. Drift between artifacts is the primary source of confusion.

7. **Learn from every change.** Every course correction — a UX refactor, a scope adjustment, a spec revision — contains a lesson about what was missed or misunderstood. Capture these lessons explicitly so they inform future iterations and future projects. The goal isn't to avoid all mistakes; it's to avoid making the same mistake twice.

---

## Product Loop

The product evolves through a repeating cycle of four activities. The cycle operates at the project level — a full pass takes the product from concept to working software. Each pass deepens understanding and refines the implementation.

```
Discovery → Specification → Planning → Execution
    ▲                                      │
    └──────────────────────────────────────┘
```

### 1. Discovery

**Purpose:** Understand what we're building and why.

**Inputs:** A rough concept, user goals, constraints.

**Outputs:**
- **Jobs to be done** — the primary lens for understanding user needs (see below)
- UX flows (how the experience feels, not just what features exist)
- Key constraints (tech, budget, timeline, team)
- Open questions (what we don't know yet)

**Jobs to be Done (JTBD):** Frame needs as jobs, not features. A job describes the outcome the user is hiring the product to achieve:

> *When [situation], I want to [motivation] so I can [expected outcome].*

Examples:
- "When I have a new data source, I want to make it searchable so I can ask questions about it."
- "When I'm in a long conversation, I want to quickly switch to another chat so I can check something without losing my place."

JTBD keeps the focus on *why* the user cares, which helps evaluate whether a given implementation actually serves the need. A feature can be functionally correct but fail the job — the multi-page navigation had all the right features but didn't serve the job of quick context-preserving chat switching.

**Key questions:**
- Who is the user and what jobs are they trying to get done?
- What does the experience look like? (wireframes, flow descriptions, ASCII mockups)
- What are the hard constraints we can't change?
- What don't we know yet, and how will we find out?

**When this happens:** Heavily at the start, then lightly at each iteration boundary as new information emerges.

### 2. Specification

**Purpose:** Define the system precisely enough to build and validate.

**Inputs:** Discovery outputs.

**Outputs:**
- **Product spec (PRD):** What the product does — capabilities, non-functional requirements, success metrics, constraints.
- **Technical spec (Architecture):** How the system works — components, data models, APIs, infrastructure.

**Acceptance criteria format (Behavior-Driven Development style):** Use Given/When/Then to make criteria precise and verifiable. This isn't about adopting BDD tooling — it's a thinking tool that forces clarity about preconditions, actions, and expected outcomes.

> **Given** [precondition/context]
> **When** [action the user takes]
> **Then** [observable outcome]

Example:
> **Given** I have a processed document in my library
> **When** I ask "What does the report say about revenue?"
> **Then** the response includes citations referencing the document, and the agent trace shows the search queries used

This format eliminates ambiguity that prose criteria leave open ("Upload a PDF and see it in the list" — what list? what state? what if it fails?).

**Key questions:**
- For each feature: what does the user see and do? What happens under the hood?
- Are there ambiguities a developer would need to resolve while building?
- Can each acceptance criterion be validated by a human in < 5 minutes?
- Do the acceptance criteria cover the job the feature serves, not just the mechanics?

**When this happens:** Heavily at the start to establish the baseline. Then updated at iteration boundaries when the spec and reality diverge.

### 3. Planning

**Purpose:** Break the work into verifiable iterations, grouped into milestones.

**Inputs:** Functional + technical specs.

**Outputs:**
- **Milestone plan:** Ordered list of milestones, each containing iterations with a clear scope, acceptance criteria, and validation steps.
- **Backlog:** Deferred items, known issues, and future opportunities — each with context on why it's deferred and when to revisit.

**Key questions:**
- Is each iteration scoped to a vertical slice (end-to-end, validatable)?
- Can the human validate each iteration in one sitting?
- What's the dependency order? Which iterations unlock others?
- What's explicitly out of scope for now, and where is that tracked?

**When this happens:** After initial specification, then revised at iteration boundaries.

### 4. Execution

**Purpose:** Execute the plan by running the Iteration Loop for each iteration.

This is where the plan becomes working software. Each iteration goes through the Iteration Loop (Scope → Align → Build → Validate → Adapt → Sync). The Product Loop resumes when:

- All planned iterations for the current milestone are complete, or
- An iteration reveals that the plan, spec, or product understanding needs revision — triggering a return to Planning, Specification, or Discovery as appropriate.

---

## The Iteration Loop

The Iteration Loop runs once per iteration. Each iteration is scoped to a vertical slice of functionality that can be built and validated in one sitting.

```
┌──────────────────────────────────────────────────────────────────────┐
│                                                                      │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────────┐   │
│   │  Scope   │───▶│  Align   │───▶│  Build   │───▶│  Validate    │   │
│   │          │    │ (human)  │    │          │    │   (human)    │   │
│   └──────────┘    └──────────┘    └────▲─────┘    └──┬────┬──────┘   │
│        ▲                               │            │    │           │
│        │                               │  ┌─────────┘    │           │
│        │                               │  │ issues       │ pass      │
│        │                               │  ▼              ▼           │
│        │                            ┌──────────┐    ┌─────────┐      │
│        │                            │  Adapt   │    │  Sync   │      │
│        │                            └──────────┘    └────┬────┘      │
│        │                                                 │           │
│        └─────────────────────────────────────────────────┘           │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

### Scope
- Define what this iteration delivers
- State acceptance criteria in Given/When/Then format
- Identify which jobs (JTBD) this iteration serves
- List what's explicitly out of scope

### Align (Human)
- Present the iteration scope to the human before building
- The human confirms the scope makes sense, or adjusts it
- This is a lightweight gate — not a lengthy approval process. The goal is to catch misalignment *before* work begins rather than after
- Adjustments here are cheap; adjustments after Build are expensive

### Build

**Purpose:** Build the iteration scope.

**Inputs:** Iteration scope, specs, codebase.

**Outputs:** Working code, tests, updated docs.

- Implement the scope
- Note any divergences from spec
- Surface decisions to the human when ambiguous

**Discipline during build:**
- Build what's in scope. Don't gold-plate, don't add "while I'm here" improvements.
- Surface decisions. If the spec is ambiguous or you're choosing between approaches, ask.
- Note divergences. If you implement something differently from spec, record it for the sync check.

### Validate (Human)

**Purpose:** Confirm the iteration works and decide what's next. This is the human's primary leverage point — the human validates, decides if it's acceptable, and steers what happens next.

- Run through the Given/When/Then acceptance criteria
- Evaluate against the JTBD: does it serve the job, not just pass the criteria?
- Evaluate the UX (does it feel right?)
- Identify issues: must-fix (blocks progress) vs. nice-to-fix (backlog)
- **Two exits:** issues found → Adapt; pass → Sync

### Adapt

**Purpose:** Fix issues and refine the implementation based on validation feedback — before moving on.

When validation reveals issues, fix them before moving on:

- Address must-fix issues identified during validation
- May involve reworking implementation, adjusting UX, or revising the approach
- Cycles back to Build → Validate — this may repeat multiple times
- Nice-to-fix items that aren't blocking go to the backlog, not into the adapt loop
- If adaptation reveals that the scope itself was wrong, escalate to re-scoping rather than quietly expanding

**The distinction from Build:** Build works from spec. Adapt works from feedback. Build is forward-looking ("implement the scope"); Adapt is corrective ("fix what validation revealed"). They use the same tools but serve different purposes.

### Sync
Once the iteration passes validation, reconcile across artifacts before starting the next iteration:

1. **Spec sync:** Do the PRD and Architecture still reflect reality? If not, update them.
2. **Plan check:** Does the remaining milestone plan still make sense? Adjust scope, reorder, add/remove iterations.
3. **Backlog triage:** Are there new deferred items? Should any existing backlog items be promoted into the next iteration?
4. **Capture lessons:** What did this iteration teach us? Record lessons in the milestone file (see Lessons Log below). Focus on *process* insights (what to do differently) and *domain* insights (what we now understand better about the problem).
5. **Direction check:** Has the human's understanding of what they want changed? If so, loop back to Discovery in the Product Loop.

---

## Artifact Inventory

Every project maintains these artifacts. They are the source of truth and must stay in sync.

| Artifact | Location | Purpose | Updated when |
|----------|----------|---------|-------------|
| **Product Spec** (PRD) | `docs/PRD.md` | What the product does | Iteration boundaries, scope changes |
| **Technical Spec** (Architecture) | `docs/ARCHITECTURE.md` | How the system works | Iteration boundaries, technical decisions |
| **Milestone Plan** | `docs/iterations/README.md` (dashboard) | Status table, unscoped milestones, backlog | Every iteration boundary |
| **Milestone Docs** | `docs/iterations/milestone-*.md` | Iteration specs, journal, lessons — one file per milestone | Every iteration boundary |
| **Validation Guide** | `docs/VALIDATION.md` | How to validate each iteration | When iterations are added/modified |
| **Backlog** | `docs/iterations/README.md` (backlog section) | Deferred items and known issues | Continuously |

---

## Milestone Documents

Each active milestone has a single document (`docs/iterations/milestone-NN.md`) that serves as the source of truth for that milestone. It contains three sections:

### Iterations
The spec for each iteration: what it delivers, acceptance criteria (Given/When/Then). Moved here from the README once the milestone is scoped. Iterations are marked ✅ when validated.

### Journal
A narrative account of each iteration — what happened, what surprised us, what the decision points looked like. Written at the Sync step. The journal serves two purposes:
1. **Context preservation** — captures the *why* and *how* that commit messages and lessons alone don't convey.
2. **Blog material** — the raw narrative for "learning in public" posts. A good journal entry can be edited into a blog post with minimal rework.

**What to capture:**
- What the original plan was and how it changed
- Surprises, dead ends, and pivots
- Key decisions and what informed them
- The experience of using a tool/framework for the first time

**Tone:** Write as if explaining to a peer who wasn't in the room. Include enough context that the entry is self-contained.

### Lessons
Terse, scannable takeaways — designed to be skimmed at planning time. These are the distilled insights from the journal.

**What to record:**
- **Process lessons** — what to do differently in how we work.
- **Domain lessons** — what we now understand better about the problem or the user.
- **Technical lessons** — what we learned about the tools, frameworks, or architecture.

**What NOT to record:**
- Bug fixes that don't reveal a process or understanding gap
- Implementation details that are already captured in code or specs

**Format:** Each lesson is a short entry tied to the iteration that produced it:

> **Iter 1.1 (Agent SDK is a CLI wrapper):** The Claude Agent SDK is not a thin API client — it spawns the Claude Code CLI as a subprocess. *Lesson: the Agent SDK owns its own LLM connection — don't try to manage it yourself.*

Lessons are reviewed at the start of each planning activity to inform how iterations are scoped and specified.

---

## Handling Change

Change is expected. The process handles it through the Sync step:

**UX doesn't feel right →** Update the functional spec (PRD) with the revised UX description. Adjust current or upcoming iteration scope. The sidebar refactor is a textbook example: the feature worked but the experience was wrong.

**Implementation diverges from spec →** Decide which is correct: the spec or the implementation. Update the loser. Don't leave them in conflict.

**New requirement discovered →** Add it to the backlog with context. Triage it at the next Sync: does it belong in the current iteration, a future one, or is it truly deferred?

**Scope too large →** Split the iteration. The sign that an iteration is too large: the human can't validate it in one sitting, or the description requires more than a short paragraph.

**Fundamental direction change →** Loop back to Discovery in the Product Loop. Update specs. Re-plan remaining milestones. This is expensive but less expensive than building the wrong thing.

---

## Anti-Patterns

| Anti-pattern | What to do instead |
|-------------|-------------------|
| Treating specs as frozen after initial creation | Update them at every iteration boundary |
| "All infrastructure" or "all backend" iterations | Deliver vertical slices that can be validated end-to-end |
| Building inside-out (data model first, UI last) | Start from the user surface and work inward; the experience should drive the internals |
| Accumulating deferred items without tracking them | Maintain a backlog with context and triage criteria |
| Building first, asking questions later | Surface ambiguities before or during building, not after |
| Moving to the next iteration with known issues | Use the adapt loop to fix must-fix issues before syncing; only nice-to-fix items go to backlog |
| Gold-plating during build | Build exactly what's in scope; improvements go to the backlog |
| Skipping the sync step after validation | Always check: does spec match reality? Does plan still make sense? |
| Letting the milestone plan live in conversation | Write it down in a durable artifact that can be referenced and revised |
| Making corrections without capturing the lesson | Record what the change taught you; lessons compound across iterations and projects |
