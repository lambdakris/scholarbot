# ScholarBot

A Deep Research agent that autonomously performs multi-hop web research to answer complex questions — built with a benchmark-driven, self-improving architecture.

## What makes this different

ScholarBot isn't just a RAG chatbot. It's built around a **four-layer optimization framework** that treats AI system development as a multi-level problem:

| Layer | What it optimizes | Tool |
|-------|-------------------|------|
| 0 — Human Validation | Dev artifacts vs. intent | [Development methodology](docs/STRATEGY.md) |
| 1 — Eval-Informed Dev | System task performance | MLflow 3.x + [DeepSearchQA](https://huggingface.co/datasets/google/deepsearchqa) benchmarks |
| 2 — Runtime Self-Optimization | System behavior in production | DSPy / MLflow feedback loops |
| 3 — Coding Agent Optimization | Agent effectiveness on this project | MLflow tracing of Claude Code |

The project also serves as a comparative study of **Claude Agents SDK vs. DSPy** as agent orchestration frameworks — not from docs, but from building the same system with both.

For the full conceptual foundation, see [FOUNDATIONS.md](docs/FOUNDATIONS.md).

## Tech stack

- **Agent**: Claude Agents SDK (Phase A), DSPy (Phase B)
- **LLM**: Claude via Azure AI Foundry
- **Backend**: FastAPI
- **Frontend**: Streamlit
- **Observability**: MLflow 3.x (tracing, evaluation, experiment tracking)
- **Web Search**: Claude Agent SDK built-in WebSearch
- **Infrastructure**: Azure Container Apps, Bicep IaC, GitHub Actions CI
- **Package Management**: UV

## Local development

### Prerequisites

- Python 3.11+
- [UV](https://docs.astral.sh/uv/)
- Docker + Docker Compose

### Setup

```bash
# Clone and install
git clone https://github.com/lambdakris/scholarbot.git
cd scholarbot
cp .env.example .env   # fill in API keys
uv sync
```

### Run

```bash
# Start all services (server + portal + MLflow)
docker compose up --build

# With hot reload
docker compose watch
```

| Service | URL |
|---------|-----|
| Portal (Streamlit) | http://localhost:8501 |
| Server (FastAPI) | http://localhost:8000 |
| MLflow UI | http://localhost:5000 |

### Azure infrastructure

See [infra/README.md](infra/README.md) for provisioning the dev environment.

## Project documentation

| Document | Purpose |
|----------|---------|
| [FOUNDATIONS.md](docs/FOUNDATIONS.md) | Four-layer optimization framework, benchmark strategy, design philosophy |
| [STRATEGY.md](docs/STRATEGY.md) | Development methodology — Milestone/Iteration structure, Iteration Loop |
| [PRD.md](docs/PRD.md) | Product requirements, JTBD, capabilities, success metrics |
| [Milestone Plan](docs/iterations/README.md) | Current status, planned milestones, backlog |

## Current status

**Milestone 1 (Baseline Agent)** — in progress. Research agent with web search operational, multi-hop verified (1.2 complete). Foundation (Milestone 0) complete.

See the [Milestone Plan](docs/iterations/README.md) for what's next.

## License

TBD
