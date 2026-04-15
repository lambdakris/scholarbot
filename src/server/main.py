import mlflow
import mlflow.anthropic  # noqa: F811 — runtime submodule, not in type stubs
from fastapi import FastAPI
from inference import research
from pydantic import BaseModel

from .settings import settings

# MLflow setup — the server owns its own observability context
mlflow.set_tracking_uri(settings.mlflow_tracking_uri)
mlflow.set_experiment("scholarbot-dev")
mlflow.anthropic.autolog()  # type: ignore[attr-defined]

# The variant currently deployed by this server
DEPLOYED_VARIANT = "v1-baseline"

app = FastAPI(title="ScholarBot API")


class ChatRequest(BaseModel):
    question: str


class ChatResponse(BaseModel):
    answer: str


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/chat")
async def chat(request: ChatRequest) -> ChatResponse:
    answer = await research(request.question, variant=DEPLOYED_VARIANT)
    return ChatResponse(answer=answer)
