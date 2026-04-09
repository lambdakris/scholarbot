# Architecture

How ScholarBot is structured, how the components interact, and the key design decisions that shaped them.

---

## System Overview

```mermaid
graph TB
    subgraph Docker Compose
        Portal["Portal<br/>(Streamlit :8501)"]
        Server["Server<br/>(FastAPI :8000)"]
        MLflow["MLflow<br/>(Tracking Server :5000)"]

        Portal -->|HTTP POST /chat| Server
    end

    Inference["Inference<br/>(Agent config + variants)"]
    Server -->|imports| Inference
    Inference -->|autolog| MLflow

    subgraph "Local (outside Docker)"
        EvalNotebook["Evaluation Notebook<br/>(dataset loading, trace generation,<br/>scoring, variant comparison)"]
        ExploreNotebook["Exploration Notebook<br/>(SDK experimentation)"]
    end

    EvalNotebook -->|imports| Inference
    EvalNotebook -->|mlflow.genai.evaluate| MLflow
    ExploreNotebook -->|imports| Inference

    Inference -->|ClaudeSDKClient| Foundry["Azure AI Foundry<br/>(Claude models)"]
    Inference -->|built-in tool| WebSearch["WebSearch"]
```

The inference module is a shared Python library, not a service. It's imported by the server (inside Docker) and by notebooks (outside Docker). This ensures the same agent logic is served and evaluated.

---

## Module Structure

```
src/
├── inference/        # Agent configuration, variants, and execution (shared)
├── evaluation/       # Dataset loaders, scorers, predict_fn helpers
├── server/           # FastAPI HTTP interface (imports inference)
└── portal/           # Streamlit UI (calls server over HTTP)

notebooks/
├── evaluation.ipynb  # Primary eval workspace (Phases B-D of eval process)
└── agent-sdk-exploration.ipynb  # SDK experimentation
```

### Inference (`src/inference/`)

The core agent logic — what the agent is and how it runs. Both the server and evaluation notebooks import from here.

Defines **agent variants**: named configurations (prompt, model, topology) representing each improvement attempt (e.g., `v1-baseline`, `v2-decompose-prompt`, `v3-sonnet-upgrade`). Exposes `get_agent_options(variant)` and `research(question, variant)`.

### Evaluation (`src/evaluation/`)

Reusable building blocks for the evaluation workflow: dataset loaders, variant-aware `predict_fn` factory, custom scorers. The evaluation notebook is the primary runner; this module provides the components.

### Server (`src/server/`)

Thin HTTP wrapper around inference. Exposes the currently deployed variant via `POST /chat`. Also serves `GET /health`.

### Portal (`src/portal/`)

Streamlit UI. Calls the server over HTTP. No dependency on inference or evaluation.

---

## Key Interfaces

### 1. Server → Inference

The server imports `research()` from inference, using the deployed variant.

```python
# src/server/main.py
from inference import research

DEPLOYED_VARIANT = "v1-baseline"

@app.post("/chat")
async def chat(request: ChatRequest) -> ChatResponse:
    answer = await research(request.question, variant=DEPLOYED_VARIANT)
    return ChatResponse(answer=answer)
```

### 2. Evaluation Notebook → Inference

The notebook creates variant-aware predict functions for MLflow evaluation.

```python
# In the evaluation notebook
import asyncio
from inference import research

def make_predict_fn(variant: str):
    def predict_fn(question: str) -> str:
        return asyncio.run(research(question, variant=variant))
    return predict_fn

def evaluate_variant(variant: str, test_cases, scorers=None):
    predict_fn = make_predict_fn(variant)
    with mlflow.start_run(run_name=variant, tags={"variant": variant}):
        return mlflow.genai.evaluate(
            data=test_cases,
            predict_fn=predict_fn,
            scorers=scorers or [],
        )
```

### 3. Portal → Server

The portal calls the server over HTTP. It has no awareness of inference, evaluation, or variants.

```python
# src/portal/main.py
response = httpx.post(f"{SERVER_URL}/chat", json={"question": question})
```

---

## Data Flow

### Research Query (User → Answer)

```mermaid
sequenceDiagram
    actor User
    participant Portal as Portal (Streamlit)
    participant Server as Server (FastAPI)
    participant Inference
    participant Claude as Claude LLM (Azure Foundry)
    participant Web as WebSearch (built-in)
    participant MLflow

    User->>Portal: Ask question
    Portal->>Server: POST /chat {question}
    Server->>Inference: research(question, variant)
    Inference->>Claude: ClaudeSDKClient.query()

    loop Agent reasoning loop
        Claude->>Web: WebSearch(query)
        Web-->>Claude: Search results
        Claude->>Claude: Reason about results
    end

    Claude-->>Inference: Final answer + sources
    Inference-->>MLflow: Trace (auto-logged)
    Inference-->>Server: answer
    Server-->>Portal: {answer}
    Portal-->>User: Display answer + sources
```

### Evaluation Cycle (Variant → Scores → Compare)

```mermaid
sequenceDiagram
    participant Notebook as Evaluation Notebook
    participant Inference
    participant Claude as Claude LLM
    participant MLflow
    participant Scorers

    Note over Notebook: Dataset loaded once, reused across cycles

    Notebook->>Notebook: evaluate_variant("v2-decompose-prompt", test_cases, scorers)
    
    loop For each dataset row (parallel)
        Notebook->>Inference: research(question, "v2-decompose-prompt")
        Inference->>Claude: Agent runs (search + reason)
        Claude-->>Inference: Answer
        Inference-->>Notebook: output + trace (auto-captured)
    end

    loop For each row
        Notebook->>Scorers: score(outputs, expectations, trace)
        Scorers-->>Notebook: Feedback (value + rationale)
    end

    Notebook->>MLflow: Log run "v2-decompose-prompt" (metrics + scores + traces)
    Notebook->>Notebook: Compare v2 metrics against v1-baseline
```

---

## Technology Decisions

| Component | Choice | Rationale |
|-----------|--------|-----------|
| Agent framework | Claude Agent SDK | Meta directive; Phase A of framework comparison |
| LLM | Claude Haiku 4.5 via Azure AI Foundry | Cost-effective for baseline; model tier is an optimization lever |
| Web search | Agent SDK built-in WebSearch | Eliminates external search dependency |
| HTTP framework | FastAPI | Async support, Pydantic models, standard |
| UI | Streamlit | Near-term simplicity; React/Next.js planned for Milestone 5 |
| Observability | MLflow 3.x | Tracing, evaluation, experiment tracking in one platform |
| Eval runner | Jupyter notebook | Interactive exploration, inline visualization, flow-state workflow |
| Eval invocation | Direct (shared inference module) | Trace correlation requires same-process execution |
| Infrastructure | Azure Container Apps + Bicep | Managed identity, production-grade skeleton |
| Package management | UV | Consistent with portfolio convention |

---

## Deployment Topology

### Local Development (current)

```mermaid
graph TB
    subgraph Docker["Docker Compose"]
        ServerSvc["server_service<br/>(FastAPI + Inference<br/>:8000, debugpy :5678)"]
        PortalSvc["portal_service<br/>(Streamlit<br/>:8501, debugpy :5679)"]
        MLflowSvc["mlflow_service<br/>(Tracking Server<br/>:5000)"]
    end

    subgraph Local["Local (outside Docker)"]
        EvalNB["Evaluation Notebook<br/>(uv run jupyter lab)"]
        ExploreNB["Exploration Notebook"]
    end

    PortalSvc -->|HTTP| ServerSvc
    ServerSvc -->|traces| MLflowSvc
    EvalNB -->|traces + evals| MLflowSvc
```

The evaluation notebook runs outside Docker because it invokes the agent directly (via the inference module) and needs MLflow trace correlation in the same process. The server runs inside Docker for consistent orchestration.

### Azure (planned — Milestone 4)

```mermaid
graph TB
    subgraph ACA["Azure Container Apps"]
        ServerApp["Server<br/>(Container App<br/>+ managed identity)"]
        PortalApp["Portal<br/>(Container App)"]
        MLflowApp["MLflow<br/>(Container App<br/>+ persistent storage)"]
    end

    subgraph Dev["Developer / CI"]
        EvalRunner["Evaluation<br/>Notebook / CI"]
    end

    PortalApp -->|HTTP| ServerApp
    ServerApp -->|traces| MLflowApp
    EvalRunner -->|traces + evals| MLflowApp
    ServerApp -->|managed identity| Foundry["Azure AI Foundry"]
```

---

## Related Documents

- [Evaluation Guide](EVAL_GUIDE.md) — process and developer experience walkthrough for measuring and improving agent quality
- [MLflow Evaluation Capabilities](EVAL_CAPABILITIES.md) — reference on MLflow's eval API and workflows
- [FOUNDATIONS.md](FOUNDATIONS.md) — four-layer optimization framework
