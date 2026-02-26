"""FastAPI application entry point."""
from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.routers import auth, knowledge, models, questions, recommendations, dashboard, upload, prediction, weekly_review, exams, flashcards, diagnosis, learning, training, strategy

# OpenAPI Tag 分组与描述
tags_metadata = [
    {"name": "健康检查", "description": "服务健康状态"},
    {"name": "认证", "description": "用户注册、登录、身份验证"},
    {"name": "题目管理", "description": "错题上传、历史记录、聚合统计"},
    {"name": "图片上传", "description": "题目图片上传"},
    {"name": "仪表盘", "description": "学习数据概览"},
    {"name": "推荐", "description": "个性化学习推荐"},
    {"name": "知识点", "description": "知识树浏览、知识点详情"},
    {"name": "解题模型", "description": "模型树浏览、模型详情"},
    {"name": "成绩预测", "description": "分数预测、趋势分析、提分路径"},
    {"name": "周报", "description": "周学习报告"},
    {"name": "考试", "description": "考试记录、热力图"},
    {"name": "闪卡复习", "description": "间隔重复复习系统"},
    {"name": "AI诊断", "description": "AI 诊断对话会话（多轮对话诊断错题根因）"},
    {"name": "知识学习", "description": "知识点学习对话会话（五步 AI 引导学习）"},
    {"name": "模型训练", "description": "🔧 Stub - 解题模型训练对话会话"},
    {"name": "卷面策略", "description": "卷面策略生成与管理（纯规则，零 LLM 成本）"},
    {"name": "📋 计划中-教育数据", "description": "需要教育数据支撑的计划端点，尚未实现"},
]

app = FastAPI(
    title="EchoMind API",
    version="0.1.0",
    description=(
        "EchoMind 错题追踪与智能学习系统 API\n\n"
        "## 认证说明\n"
        "除标注「无需认证」的端点外，所有请求需在 Header 中携带：\n"
        "`Authorization: Bearer <access_token>`\n\n"
        "Token 通过 `/api/auth/register` 或 `/api/auth/login` 获取。\n\n"
        "## 端点状态\n"
        "- ✅ 完整实现（21 个）\n"
        "- 🔧 Stub — 返回空/初始结构，待填充真实逻辑（3 个）\n"
        "- 📋 计划中 — 需要教育数据支撑，尚未实现\n"
    ),
    openapi_tags=tags_metadata,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/api")
app.include_router(knowledge.router, prefix="/api")
app.include_router(models.router, prefix="/api")
app.include_router(questions.router, prefix="/api")
app.include_router(recommendations.router, prefix="/api")
app.include_router(dashboard.router, prefix="/api")
app.include_router(upload.router, prefix="/api")
app.include_router(prediction.router, prefix="/api")
app.include_router(weekly_review.router, prefix="/api")
app.include_router(exams.router, prefix="/api")
app.include_router(flashcards.router, prefix="/api")
app.include_router(diagnosis.router, prefix="/api")
app.include_router(learning.router, prefix="/api")
app.include_router(training.router, prefix="/api")
app.include_router(strategy.router, prefix="/api")

# 静态文件服务 — 图片上传目录
_uploads_dir = Path(__file__).resolve().parents[1] / "uploads"
_uploads_dir.mkdir(parents=True, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=str(_uploads_dir)), name="uploads")


@app.get("/health", tags=["健康检查"])
async def health():
    return {"status": "ok"}
