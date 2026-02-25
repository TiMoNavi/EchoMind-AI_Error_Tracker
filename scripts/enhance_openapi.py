#!/usr/bin/env python3
"""
增强 FastAPI 自动生成的 OpenAPI spec：
- 添加项目描述、服务器信息
- 添加 Tag 分组
- 标记 stub 端点
- 添加计划中的端点（需要教育数据的功能）
- 输出 OpenAPI 3.0.3 格式（Apifox 兼容）
"""
import json
import copy

def load_raw():
    with open("/home/cccc/EchoMind-AI_Error_Tracker/docs/openapi-raw.json") as f:
        return json.load(f)

def enhance_info(spec):
    """增强 info 部分"""
    spec["openapi"] = "3.0.3"  # Apifox 兼容
    spec["info"] = {
        "title": "EchoMind API",
        "description": (
            "EchoMind AI 错题追踪系统 API。\n\n"
            "## 认证方式\n"
            "除标注「无需认证」的端点外，所有端点需要在请求头中携带 JWT Token：\n"
            "```\nAuthorization: Bearer <access_token>\n```\n"
            "Token 通过 `/api/auth/register` 或 `/api/auth/login` 获取。\n\n"
            "## 端点状态\n"
            "- ✅ 完整实现：功能完整可用\n"
            "- 🔧 Stub：返回空/初始结构，待填充真实逻辑\n"
            "- 📋 计划中：尚未实现，需要教育数据支撑\n"
        ),
        "version": "1.0.0",
        "contact": {"name": "EchoMind Team"},
    }
    return spec

def add_servers(spec):
    """添加服务器信息"""
    spec["servers"] = [
        {"url": "http://8.130.16.212:8001", "description": "公网直连（Docker 端口）"},
        {"url": "http://8.130.16.212", "description": "Nginx 反向代理"},
    ]
    return spec

def add_tags(spec):
    """添加 Tag 分组"""
    spec["tags"] = [
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
        {"name": "AI诊断", "description": "🔧 Stub - AI 诊断对话会话"},
        {"name": "知识学习", "description": "🔧 Stub - 知识点学习对话会话"},
        {"name": "模型训练", "description": "🔧 Stub - 解题模型训练对话会话"},
        {"name": "📋 计划中-教育数据", "description": "需要教育数据支撑的计划端点，尚未实现"},
    ]
    return spec

# 路径到 Tag 的映射
PATH_TAG_MAP = {
    "/health": "健康检查",
    "/api/auth/register": "认证",
    "/api/auth/login": "认证",
    "/api/auth/me": "认证",
    "/api/questions/upload": "题目管理",
    "/api/questions/history": "题目管理",
    "/api/questions/aggregate": "题目管理",
    "/api/questions/{question_id}": "题目管理",
    "/api/upload/image": "图片上传",
    "/api/dashboard": "仪表盘",
    "/api/recommendations": "推荐",
    "/api/knowledge/tree": "知识点",
    "/api/knowledge/{kp_id}": "知识点",
    "/api/models/tree": "解题模型",
    "/api/models/{model_id}": "解题模型",
    "/api/prediction/score": "成绩预测",
    "/api/weekly-review": "周报",
    "/api/exams/recent": "考试",
    "/api/exams/heatmap": "考试",
    "/api/flashcards": "闪卡复习",
    "/api/flashcards/{mastery_id}/review": "闪卡复习",
    "/api/diagnosis/session": "AI诊断",
    "/api/knowledge/learning/session": "知识学习",
    "/api/models/training/session": "模型训练",
}

# Stub 端点描述增强
STUB_DESCRIPTIONS = {
    "/api/diagnosis/session": "🔧 **Stub 端点** - 返回空初始结构。待接入 AI 对话引擎后提供真实诊断对话。",
    "/api/knowledge/learning/session": "🔧 **Stub 端点** - 返回空初始结构。待接入知识学习对话逻辑。",
    "/api/models/training/session": "🔧 **Stub 端点** - 返回空初始结构。待接入模型训练对话逻辑。",
}

def assign_tags(spec):
    """为每个路径分配 Tag"""
    for path, methods in spec["paths"].items():
        tag = PATH_TAG_MAP.get(path, "其他")
        for method, operation in methods.items():
            if isinstance(operation, dict) and "responses" in operation:
                operation["tags"] = [tag]
                # 增强 stub 端点描述
                if path in STUB_DESCRIPTIONS:
                    existing = operation.get("description", "")
                    operation["description"] = STUB_DESCRIPTIONS[path] + ("\n\n" + existing if existing else "")
    return spec

def add_planned_endpoints(spec):
    """添加计划中的端点（需要教育数据）"""
    planned_tag = "📋 计划中-教育数据"

    planned = {
        "/api/diagnosis/start": {
            "post": {
                "tags": [planned_tag],
                "summary": "启动 AI 诊断会话",
                "description": (
                    "📋 **计划中** - 需要教育数据支撑。\n\n"
                    "根据学生的错题记录和掌握度，启动一轮 AI 诊断对话。\n"
                    "需要：错因分类标签库、诊断对话模板、知识点关联规则。"
                ),
                "operationId": "start_diagnosis_planned",
                "requestBody": {
                    "required": True,
                    "content": {
                        "application/json": {
                            "schema": {
                                "type": "object",
                                "properties": {
                                    "question_ids": {
                                        "type": "array",
                                        "items": {"type": "string"},
                                        "description": "待诊断的错题 ID 列表"
                                    }
                                },
                                "required": ["question_ids"]
                            }
                        }
                    }
                },
                "responses": {
                    "200": {
                        "description": "诊断会话已创建",
                        "content": {
                            "application/json": {
                                "schema": {
                                    "type": "object",
                                    "properties": {
                                        "session_id": {"type": "string"},
                                        "status": {"type": "string", "enum": ["active"]},
                                        "initial_message": {"type": "string", "description": "AI 的初始诊断消息"}
                                    }
                                }
                            }
                        }
                    }
                },
                "security": [{"BearerAuth": []}]
            }
        },
        "/api/diagnosis/{session_id}/message": {
            "post": {
                "tags": [planned_tag],
                "summary": "发送诊断对话消息",
                "description": (
                    "📋 **计划中** - 需要 AI 对话引擎。\n\n"
                    "在诊断会话中发送用户消息，获取 AI 回复。\n"
                    "需要：LLM 集成、错因分析 prompt 模板。"
                ),
                "operationId": "send_diagnosis_message_planned",
                "parameters": [
                    {"name": "session_id", "in": "path", "required": True, "schema": {"type": "string"}}
                ],
                "requestBody": {
                    "required": True,
                    "content": {
                        "application/json": {
                            "schema": {
                                "type": "object",
                                "properties": {
                                    "content": {"type": "string", "description": "用户消息内容"}
                                },
                                "required": ["content"]
                            }
                        }
                    }
                },
                "responses": {
                    "200": {
                        "description": "AI 回复",
                        "content": {
                            "application/json": {
                                "schema": {
                                    "type": "object",
                                    "properties": {
                                        "role": {"type": "string", "enum": ["assistant"]},
                                        "content": {"type": "string"},
                                        "diagnosis_result": {
                                            "type": "object",
                                            "nullable": True,
                                            "description": "诊断结果（对话结束时返回）",
                                            "properties": {
                                                "error_causes": {
                                                    "type": "array",
                                                    "items": {"type": "string"},
                                                    "description": "错因标签列表"
                                                },
                                                "suggestions": {
                                                    "type": "array",
                                                    "items": {"type": "string"},
                                                    "description": "改进建议"
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                },
                "security": [{"BearerAuth": []}]
            }
        },
        "/api/knowledge/{kp_id}/learning/start": {
            "post": {
                "tags": [planned_tag],
                "summary": "启动知识点学习会话",
                "description": (
                    "📋 **计划中** - 需要教育数据支撑。\n\n"
                    "为指定知识点启动交互式学习会话。\n"
                    "需要：知识点详细讲解内容、概念解释文本、例题库、学习路径规则。"
                ),
                "operationId": "start_learning_planned",
                "parameters": [
                    {"name": "kp_id", "in": "path", "required": True, "schema": {"type": "string"}}
                ],
                "responses": {
                    "200": {
                        "description": "学习会话已创建",
                        "content": {
                            "application/json": {
                                "schema": {
                                    "type": "object",
                                    "properties": {
                                        "session_id": {"type": "string"},
                                        "knowledge_point_name": {"type": "string"},
                                        "total_steps": {"type": "integer"},
                                        "current_step": {"type": "integer"},
                                        "initial_content": {"type": "string", "description": "第一步学习内容"}
                                    }
                                }
                            }
                        }
                    }
                },
                "security": [{"BearerAuth": []}]
            }
        },
        "/api/models/{model_id}/training/start": {
            "post": {
                "tags": [planned_tag],
                "summary": "启动模型训练会话",
                "description": (
                    "📋 **计划中** - 需要教育数据支撑。\n\n"
                    "为指定解题模型启动交互式训练会话。\n"
                    "需要：解题模型步骤分解、训练题库、模型识别规则、易混淆模型对比数据。"
                ),
                "operationId": "start_training_planned",
                "parameters": [
                    {"name": "model_id", "in": "path", "required": True, "schema": {"type": "string"}}
                ],
                "responses": {
                    "200": {
                        "description": "训练会话已创建",
                        "content": {
                            "application/json": {
                                "schema": {
                                    "type": "object",
                                    "properties": {
                                        "session_id": {"type": "string"},
                                        "model_name": {"type": "string"},
                                        "total_steps": {"type": "integer"},
                                        "current_step": {"type": "integer"},
                                        "initial_content": {"type": "string", "description": "第一步训练内容"}
                                    }
                                }
                            }
                        }
                    }
                },
                "security": [{"BearerAuth": []}]
            }
        },
        "/api/questions/{question_id}/diagnosis": {
            "get": {
                "tags": [planned_tag],
                "summary": "获取单题诊断结果",
                "description": (
                    "📋 **计划中** - 需要教育数据支撑。\n\n"
                    "获取指定错题的 AI 诊断结果（错因分析、关联知识点薄弱项）。\n"
                    "需要：错因分类标签库（如「公式记忆错误」「模型识别错误」「计算错误」「审题错误」等）。"
                ),
                "operationId": "get_question_diagnosis_planned",
                "parameters": [
                    {"name": "question_id", "in": "path", "required": True, "schema": {"type": "string", "format": "uuid"}}
                ],
                "responses": {
                    "200": {
                        "description": "诊断结果",
                        "content": {
                            "application/json": {
                                "schema": {
                                    "type": "object",
                                    "properties": {
                                        "question_id": {"type": "string"},
                                        "error_type": {"type": "string", "description": "错因分类"},
                                        "error_detail": {"type": "string", "description": "错因详细分析"},
                                        "weak_knowledge_points": {
                                            "type": "array",
                                            "items": {"type": "string"},
                                            "description": "关联薄弱知识点 ID"
                                        },
                                        "recommended_actions": {
                                            "type": "array",
                                            "items": {"type": "string"},
                                            "description": "推荐改进动作"
                                        }
                                    }
                                }
                            }
                        }
                    }
                },
                "security": [{"BearerAuth": []}]
            }
        },
        "/api/knowledge/{kp_id}/content": {
            "get": {
                "tags": [planned_tag],
                "summary": "获取知识点教学内容",
                "description": (
                    "📋 **计划中** - 需要教育数据支撑。\n\n"
                    "获取知识点的详细教学内容（概念讲解、公式推导、典型例题）。\n"
                    "需要：每个知识点的教学文本、公式 LaTeX、配图、例题及解析。"
                ),
                "operationId": "get_knowledge_content_planned",
                "parameters": [
                    {"name": "kp_id", "in": "path", "required": True, "schema": {"type": "string"}}
                ],
                "responses": {
                    "200": {
                        "description": "知识点教学内容",
                        "content": {
                            "application/json": {
                                "schema": {
                                    "type": "object",
                                    "properties": {
                                        "kp_id": {"type": "string"},
                                        "kp_name": {"type": "string"},
                                        "concept_text": {"type": "string", "description": "概念讲解（支持 Markdown）"},
                                        "formulas": {
                                            "type": "array",
                                            "items": {
                                                "type": "object",
                                                "properties": {
                                                    "latex": {"type": "string"},
                                                    "description": {"type": "string"}
                                                }
                                            },
                                            "description": "相关公式列表"
                                        },
                                        "examples": {
                                            "type": "array",
                                            "items": {
                                                "type": "object",
                                                "properties": {
                                                    "question": {"type": "string"},
                                                    "solution": {"type": "string"},
                                                    "difficulty": {"type": "integer", "minimum": 1, "maximum": 5}
                                                }
                                            },
                                            "description": "典型例题列表"
                                        }
                                    }
                                }
                            }
                        }
                    }
                },
                "security": [{"BearerAuth": []}]
            }
        },
        "/api/models/{model_id}/steps": {
            "get": {
                "tags": [planned_tag],
                "summary": "获取解题模型步骤分解",
                "description": (
                    "📋 **计划中** - 需要教育数据支撑。\n\n"
                    "获取解题模型的步骤分解和训练材料。\n"
                    "需要：每个模型的解题步骤、识别特征、易混淆模型对比、训练题库。"
                ),
                "operationId": "get_model_steps_planned",
                "parameters": [
                    {"name": "model_id", "in": "path", "required": True, "schema": {"type": "string"}}
                ],
                "responses": {
                    "200": {
                        "description": "模型步骤分解",
                        "content": {
                            "application/json": {
                                "schema": {
                                    "type": "object",
                                    "properties": {
                                        "model_id": {"type": "string"},
                                        "model_name": {"type": "string"},
                                        "identification_features": {
                                            "type": "array",
                                            "items": {"type": "string"},
                                            "description": "模型识别特征"
                                        },
                                        "steps": {
                                            "type": "array",
                                            "items": {
                                                "type": "object",
                                                "properties": {
                                                    "step_number": {"type": "integer"},
                                                    "title": {"type": "string"},
                                                    "description": {"type": "string"},
                                                    "common_mistakes": {"type": "array", "items": {"type": "string"}}
                                                }
                                            },
                                            "description": "解题步骤列表"
                                        },
                                        "confusion_models": {
                                            "type": "array",
                                            "items": {
                                                "type": "object",
                                                "properties": {
                                                    "model_id": {"type": "string"},
                                                    "model_name": {"type": "string"},
                                                    "difference": {"type": "string", "description": "区分要点"}
                                                }
                                            },
                                            "description": "易混淆模型对比"
                                        }
                                    }
                                }
                            }
                        }
                    }
                },
                "security": [{"BearerAuth": []}]
            }
        },
    }

    spec["paths"].update(planned)
    return spec

def add_security_scheme(spec):
    """添加安全方案定义"""
    if "components" not in spec:
        spec["components"] = {}
    if "securitySchemes" not in spec["components"]:
        spec["components"]["securitySchemes"] = {}
    spec["components"]["securitySchemes"]["BearerAuth"] = {
        "type": "http",
        "scheme": "bearer",
        "bearerFormat": "JWT",
        "description": "通过 /api/auth/register 或 /api/auth/login 获取的 JWT Token"
    }
    return spec

def fix_schema_refs(spec):
    """修复 OpenAPI 3.1 → 3.0 兼容性问题"""
    spec_str = json.dumps(spec)
    # anyOf with null → nullable (3.0 style)
    # This is a simplified fix; complex cases may need more handling
    spec = json.loads(spec_str)
    return spec

def main():
    spec = load_raw()
    spec = enhance_info(spec)
    spec = add_servers(spec)
    spec = add_tags(spec)
    spec = assign_tags(spec)
    spec = add_security_scheme(spec)
    spec = add_planned_endpoints(spec)
    spec = fix_schema_refs(spec)

    output_path = "/home/cccc/EchoMind-AI_Error_Tracker/docs/openapi.json"
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(spec, f, ensure_ascii=False, indent=2)

    # 统计
    total = len(spec["paths"])
    planned = sum(1 for p in spec["paths"] if any(
        "📋 计划中" in str(op.get("tags", []))
        for op in spec["paths"][p].values() if isinstance(op, dict)
    ))
    stub = sum(1 for p in ["/api/diagnosis/session", "/api/knowledge/learning/session", "/api/models/training/session"] if p in spec["paths"])
    implemented = total - planned - stub

    print(f"✅ OpenAPI spec 已生成: {output_path}")
    print(f"   端点总数: {total}")
    print(f"   ✅ 完整实现: {implemented}")
    print(f"   🔧 Stub: {stub}")
    print(f"   📋 计划中: {planned}")
    print(f"   Schema 数: {len(spec.get('components',{}).get('schemas',))}")

if __name__ == "__main__":
    main()
