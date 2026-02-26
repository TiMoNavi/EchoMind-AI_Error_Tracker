from abc import ABC, abstractmethod


class LLMClient(ABC):
    """LLM 供应商抽象接口，支持热切换"""

    @abstractmethod
    async def chat(
        self,
        messages: list[dict],  # [{"role": "system"|"user"|"assistant", "content": "..."}]
        temperature: float = 0.7,
        max_tokens: int = 1024,
    ) -> dict:
        """
        发送对话请求并返回结果。

        Args:
            messages: OpenAI 格式的消息列表
            temperature: 温度参数，控制输出随机性
            max_tokens: 单次最大输出 token 数

        Returns:
            {"content": str, "usage": {"input_tokens": int, "output_tokens": int}}
        """
        ...
