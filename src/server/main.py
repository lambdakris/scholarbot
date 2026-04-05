import mlflow
import mlflow.anthropic  # noqa: F811 — runtime submodule, not in type stubs
from claude_agent_sdk import ClaudeAgentOptions, ClaudeSDKClient, ResultMessage
from fastapi import FastAPI
from pydantic import BaseModel

from .settings import settings

mlflow.set_tracking_uri(settings.mlflow_tracking_uri)
mlflow.set_experiment("scholarbot-dev")
mlflow.anthropic.autolog()  # type: ignore[attr-defined]

app = FastAPI(title="ScholarBot API")

AGENT_OPTIONS = ClaudeAgentOptions(
    model="claude-haiku-4-5",
    permission_mode="bypassPermissions",
    allowed_tools=["WebSearch", "WebFetch"],
    system_prompt=(
        "You are ScholarBot, a research assistant. "
        "When asked a question, use web search to find current, accurate information. "
        "Provide a clear answer with cited sources (include URLs)."
    ),
    max_turns=10,
)


class ChatRequest(BaseModel):
    question: str


class ChatResponse(BaseModel):
    answer: str


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/chat")
async def chat(request: ChatRequest) -> ChatResponse:
    result = ""
    async with ClaudeSDKClient(options=AGENT_OPTIONS) as client:
        await client.query(request.question)
        async for message in client.receive_response():
            if isinstance(message, ResultMessage):
                result = message.result or ""
    return ChatResponse(answer=result)
