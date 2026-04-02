import mlflow
from anthropic import AnthropicFoundry
from fastapi import FastAPI
from pydantic import BaseModel

from .settings import settings

mlflow.set_tracking_uri(settings.mlflow_tracking_uri)
mlflow.set_experiment("scholarbot-dev")
mlflow.anthropic.autolog()

app = FastAPI(title="ScholarBot API")

client = AnthropicFoundry(
    api_key=settings.anthropic_api_key,
    base_url=settings.azure_foundry_base_url,
)


class ChatRequest(BaseModel):
    question: str


class ChatResponse(BaseModel):
    answer: str


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/chat")
def chat(request: ChatRequest) -> ChatResponse:
    message = client.messages.create(
        model=settings.azure_foundry_deployment,
        max_tokens=1024,
        messages=[{"role": "user", "content": request.question}],
    )
    return ChatResponse(answer=message.content[0].text)
