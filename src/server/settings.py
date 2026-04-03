from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    anthropic_api_key: str
    azure_foundry_base_url: str
    azure_foundry_deployment: str
    mlflow_tracking_uri: str = "http://mlflow_service:5000"

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8"}


settings = Settings()  # type: ignore[call-arg]  # populated from env vars
