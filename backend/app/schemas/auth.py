"""Auth request/response schemas."""
from pydantic import BaseModel


class RegisterRequest(BaseModel):
    phone: str
    password: str
    region_id: str
    subject: str
    target_score: int
    nickname: str | None = None


class LoginRequest(BaseModel):
    phone: str
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


class AuthResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: "UserResponse"


class UserResponse(BaseModel):
    id: str
    phone: str
    nickname: str | None
    region_id: str
    subject: str
    target_score: int
    predicted_score: float | None

    model_config = {"from_attributes": True}
