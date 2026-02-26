from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    database_url: str = "postgresql+asyncpg://postgres:postgres@localhost:5432/echomind"
    secret_key: str = "change-me-in-production"
    access_token_expire_minutes: int = 1440
    algorithm: str = "HS256"

    # LLM 配置
    llm_provider: str = "gemini"
    llm_api_key: str = ""
    llm_model: str = "gemini-3.0-flash"
    llm_max_tokens: int = 1024
    llm_temperature: float = 0.7
    llm_proxy: str = ""  # HTTP 代理地址，如 http://127.0.0.1:7890

    model_config = {"env_file": ".env", "extra": "ignore"}


settings = Settings()
