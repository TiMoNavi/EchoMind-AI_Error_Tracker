from app.core.config import settings
from app.core.llm_client import LLMClient


def create_llm_client() -> LLMClient:
    """根据配置创建 LLM 客户端实例"""
    provider = settings.llm_provider.lower()
    if provider == "gemini":
        from app.core.llm_gemini import GeminiClient

        return GeminiClient(
            api_key=settings.llm_api_key,
            model=settings.llm_model,
            proxy=settings.llm_proxy,
        )
    elif provider == "dashscope":
        from app.core.llm_dashscope import DashScopeClient

        return DashScopeClient(api_key=settings.llm_api_key, model=settings.llm_model)
    else:
        raise ValueError(f"Unsupported LLM provider: {provider}")
