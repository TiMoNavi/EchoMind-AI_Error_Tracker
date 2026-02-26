"""Auth request/response schemas."""
from typing import Literal, Optional
from pydantic import BaseModel, Field

# 枚举常量
VALID_REGIONS = Literal["tianjin", "beijing", "shanghai", "national"]
VALID_SUBJECTS = Literal["physics", "math", "chemistry"]


class RegisterRequest(BaseModel):
    phone: str = Field(description="手机号，用于登录凭证，需唯一")
    password: str = Field(description="登录密码")
    region_id: VALID_REGIONS = Field(description="考区/地区 ID，决定使用哪套知识点和解题模型体系")
    subject: VALID_SUBJECTS = Field(description="学科，决定加载哪个学科的知识树和模型树")
    target_score: int = Field(ge=30, le=100, description="目标分数（30-100），用于成绩预测和提分路径计算")
    nickname: str | None = Field(default=None, description="用户昵称，选填")


class LoginRequest(BaseModel):
    phone: str = Field(description="注册时使用的手机号")
    password: str = Field(description="登录密码")


class TokenResponse(BaseModel):
    access_token: str = Field(description="JWT 访问令牌")
    token_type: str = Field(default="bearer", description="令牌类型，固定为 bearer")


class AuthResponse(BaseModel):
    access_token: str = Field(description="JWT 访问令牌，后续请求需在 Authorization header 中携带")
    token_type: str = Field(default="bearer", description="令牌类型，固定为 bearer")
    user: "UserResponse" = Field(description="用户信息")


class UserResponse(BaseModel):
    id: str = Field(description="用户唯一 ID (UUID)")
    phone: str = Field(description="手机号")
    nickname: str | None = Field(description="用户昵称")
    avatar_url: str | None = Field(default=None, description="头像 URL")
    region_id: str = Field(description="考区/地区 ID (tianjin/beijing/shanghai/national)")
    subject: str = Field(description="学科 (physics/math/chemistry)")
    target_score: int = Field(description="目标分数 (30-100)")
    predicted_score: float | None = Field(description="AI 预测分数，无数据时为 null")

    model_config = {"from_attributes": True}


class ProfileUpdate(BaseModel):
    """个人资料更新请求，所有字段可选，仅更新传入的字段。"""
    nickname: Optional[str] = Field(default=None, description="用户昵称")
    avatar_url: Optional[str] = Field(default=None, description="头像 URL")
    target_score: Optional[int] = Field(default=None, ge=30, le=100, description="目标分数 (30-100)")
