import httpx

from app.core.llm_client import LLMClient


class GeminiClient(LLMClient):
    """Google Gemini API（原生格式）"""

    BASE_URL = "https://generativelanguage.googleapis.com/v1beta"

    def __init__(self, api_key: str, model: str = "gemini-2.0-flash", proxy: str = ""):
        self.api_key = api_key
        self.model = model
        self.proxy = proxy or None

    async def chat(self, messages, temperature=0.7, max_tokens=1024):
        contents = self._convert_messages(messages)
        async with httpx.AsyncClient(timeout=60, proxy=self.proxy) as client:
            resp = await client.post(
                f"{self.BASE_URL}/models/{self.model}:generateContent",
                params={"key": self.api_key},
                json={
                    "contents": contents,
                    "generationConfig": {
                        "temperature": temperature,
                        "maxOutputTokens": max_tokens,
                    },
                },
            )
            resp.raise_for_status()
            data = resp.json()
            text = data["candidates"][0]["content"]["parts"][0]["text"]
            usage = data.get("usageMetadata", {})
            return {
                "content": text,
                "usage": {
                    "input_tokens": usage.get("promptTokenCount", 0),
                    "output_tokens": usage.get("candidatesTokenCount", 0),
                },
            }

    def _convert_messages(self, messages: list[dict]) -> list[dict]:
        """OpenAI 格式 → Gemini contents 格式

        system message 拼接到第一条 user message 前面，
        assistant 角色映射为 model。
        """
        contents = []
        system_text = ""
        for msg in messages:
            if msg["role"] == "system":
                system_text = msg["content"]
            elif msg["role"] == "user":
                text = f"{system_text}\n\n{msg['content']}" if system_text else msg["content"]
                contents.append({"role": "user", "parts": [{"text": text}]})
                system_text = ""  # system 只拼接一次
            elif msg["role"] == "assistant":
                contents.append({"role": "model", "parts": [{"text": msg["content"]}]})
        return contents
