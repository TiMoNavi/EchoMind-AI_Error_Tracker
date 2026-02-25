# EchoMind API 参考文档

> 基址：`http://8.130.16.212:8001`
> 认证方式：Bearer Token（JWT），在 `Authorization` 头中传递
> 生成时间：2026-02-24
> 端点总数：23（含 1 个健康检查 + 19 个完整实现 + 3 个 stub）

## 目录

| # | 模块 | 端点数 | 状态 |
|---|------|--------|------|
| 1 | [健康检查](#1-健康检查) | 1 | ✅ |
| 2 | [认证 Auth](#2-认证模块-auth) | 3 | ✅ |
| 3 | [题目 Questions](#3-题目模块-questions) | 4 | ✅ |
| 4 | [图片上传 Upload](#4-图片上传-upload) | 1 | ✅ |
| 5 | [仪表盘 Dashboard](#5-仪表盘-dashboard) | 1 | ✅ |
| 6 | [推荐 Recommendations](#6-推荐模块-recommendations) | 1 | ✅ |
| 7 | [知识点 Knowledge](#7-知识点模块-knowledge) | 2 | ✅ |
| 8 | [解题模型 Models](#8-解题模型模块-models) | 2 | ✅ |
| 9 | [成绩预测 Prediction](#9-成绩预测-prediction) | 1 | ✅ |
| 10 | [周报 Weekly Review](#10-周报-weekly-review) | 1 | ✅ |
| 11 | [考试 Exams](#11-考试模块-exams) | 2 | ✅ |
| 12 | [闪卡 Flashcards](#12-闪卡模块-flashcards) | 2 | ✅ |
| 13 | [AI 诊断 Diagnosis](#13-ai-诊断会话-diagnosis) | 1 | 🔧 |
| 14 | [知识学习 Learning](#14-知识学习会话-learning) | 1 | 🔧 |
| 15 | [模型训练 Training](#15-模型训练会话-training) | 1 | 🔧 |

> ✅ = 完整实现 &nbsp; 🔧 = Stub（返回空/初始结构，待填充真实逻辑）

---

## 1. 健康检查

### GET /health

- 认证：无
- 请求参数：无
- 响应：
```json
{"status": "ok"}
```
- curl 示例：
```bash
curl http://8.130.16.212:8001/health
```
- 状态：✅ 完整实现

---

## 2. 认证模块 Auth

### POST /api/auth/register

- 认证：无
- 请求体：
```json
{
  "phone": "13800000001",
  "password": "test1234",
  "nickname": "张三",
  "region_id": "tianjin",
  "subject": "physics",
  "target_score": 80
}
```
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| phone | string | ✅ | 手机号 |
| password | string | ✅ | 密码 |
| region_id | string | ✅ | 地区 ID |
| subject | string | ✅ | 科目 |
| target_score | int | ✅ | 目标分数 |
| nickname | string | ❌ | 昵称 |

- 响应（201）：
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "bearer",
  "user": {
    "id": "uuid",
    "phone": "13800000001",
    "nickname": "张三",
    "region_id": "tianjin",
    "subject": "physics",
    "target_score": 80,
    "predicted_score": null
  }
}
```
- 错误码：`409` 手机号已注册
- curl 示例：
```bash
curl -X POST http://8.130.16.212:8001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"phone":"13800000001","password":"test1234","nickname":"张三","region_id":"tianjin","subject":"physics","target_score":80}'
```
- 状态：✅ 完整实现

---

### POST /api/auth/login

- 认证：无
- 请求体：
```json
{
  "phone": "13800000001",
  "password": "test1234"
}
```
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| phone | string | ✅ | 手机号 |
| password | string | ✅ | 密码 |

- 响应（200）：
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "bearer",
  "user": {
    "id": "uuid",
    "phone": "13800000001",
    "nickname": "张三",
    "region_id": "tianjin",
    "subject": "physics",
    "target_score": 80,
    "predicted_score": 65.5
  }
}
```
- 错误码：`401` 用户名或密码错误
- curl 示例：
```bash
curl -X POST http://8.130.16.212:8001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"13800000001","password":"test1234"}'
```
- 状态：✅ 完整实现

---

### GET /api/auth/me

- 认证：✅ JWT
- 请求参数：无
- 响应（200）：
```json
{
  "id": "uuid",
  "phone": "13800000001",
  "nickname": "张三",
  "region_id": "tianjin",
  "subject": "physics",
  "target_score": 80,
  "predicted_score": 65.5
}
```
- 错误码：`401/403` 未认证
- curl 示例：
```bash
curl http://8.130.16.212:8001/api/auth/me \
  -H "Authorization: Bearer <token>"
```
- 状态：✅ 完整实现

---

## 3. 题目模块 Questions

### POST /api/questions/upload

- 认证：✅ JWT
- 请求体：
```json
{
  "image_url": "https://example.com/photo.png",
  "is_correct": true,
  "source": "manual",
  "primary_model_id": "model_newton_app",
  "related_kp_ids": ["kp_newton_second", "kp_friction"]
}
```
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| image_url | string | ❌ | 题目图片 URL |
| is_correct | bool | ❌ | 是否做对 |
| source | string | ❌ | 来源，默认 `"manual"` |
| primary_model_id | string | ❌ | 关联解题模型 ID |
| related_kp_ids | list[string] | ❌ | 关联知识点 ID 列表 |

- 响应（201）：
```json
{
  "id": "uuid",
  "image_url": "https://example.com/photo.png",
  "is_correct": true,
  "source": "manual",
  "diagnosis_status": "pending",
  "created_at": "2026-02-24T12:00:00"
}
```
- 备注：上传后自动触发 mastery 更新（需提供 primary_model_id 或 related_kp_ids）
- curl 示例：
```bash
curl -X POST http://8.130.16.212:8001/api/questions/upload \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"image_url":"https://example.com/photo.png","is_correct":true,"source":"manual","primary_model_id":"model_newton_app","related_kp_ids":["kp_newton_second"]}'
```
- 状态：✅ 完整实现

---

### GET /api/questions/history

- 认证：✅ JWT
- 请求参数：无
- 响应（200）：
```json
[
  {
    "date": "2026-02-24",
    "questions": [
      {
        "id": "uuid",
        "image_url": "https://example.com/photo.png",
        "is_correct": true,
        "source": "manual",
        "diagnosis_status": "pending",
        "created_at": "2026-02-24T12:00:00"
      }
    ]
  }
]
```
- curl 示例：
```bash
curl http://8.130.16.212:8001/api/questions/history \
  -H "Authorization: Bearer <token>"
```
- 状态：✅ 完整实现

---

### GET /api/questions/aggregate

- 认证：✅ JWT
- 请求参数：

| 参数 | 位置 | 类型 | 必填 | 说明 |
|------|------|------|------|------|
| group_by | query | string | ❌ | 聚合维度，默认 `"model"`，可选 `"model"` / `"knowledge"` |

- 响应（200）：
```json
[
  {
    "target_id": "model_newton_app",
    "target_name": "牛顿定律应用",
    "total": 5,
    "error_count": 2
  }
]
```
- curl 示例：
```bash
curl "http://8.130.16.212:8001/api/questions/aggregate?group_by=model" \
  -H "Authorization: Bearer <token>"
```
- 状态：✅ 完整实现

---

### GET /api/questions/{question_id}

- 认证：✅ JWT
- 路径参数：

| 参数 | 类型 | 说明 |
|------|------|------|
| question_id | string (UUID) | 题目 ID |

- 响应（200）：
```json
{
  "id": "uuid",
  "image_url": "https://example.com/photo.png",
  "is_correct": true,
  "source": "manual",
  "diagnosis_status": "pending",
  "diagnosis_result": null,
  "created_at": "2026-02-24T12:00:00",
  "primary_model_id": "model_newton_app",
  "related_kp_ids": ["kp_newton_second"]
}
```
- 错误码：`404` 题目不存在（含非 UUID 格式）
- curl 示例：
```bash
curl http://8.130.16.212:8001/api/questions/<question_id> \
  -H "Authorization: Bearer <token>"
```
- 状态：✅ 完整实现

---

## 4. 图片上传 Upload

### POST /api/upload/image

- 认证：✅ JWT
- 请求体：`multipart/form-data`

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| file | File | ✅ | 图片文件（仅 jpg/png，最大 10MB） |

- 响应（200）：
```json
{
  "image_url": "/uploads/919dbe93-f4d6-4720-876f-0fe2a266f006.jpg",
  "image_id": "919dbe93-f4d6-4720-876f-0fe2a266f006"
}
```
- 错误码：`400` 文件类型不支持 / 超过 10MB
- curl 示例：
```bash
curl -X POST http://8.130.16.212:8001/api/upload/image \
  -H "Authorization: Bearer <token>" \
  -F "file=@/path/to/photo.jpg"
```
- 状态：✅ 完整实现

---

## 5. 仪表盘 Dashboard

### GET /api/dashboard

- 认证：✅ JWT
- 请求参数：无
- 响应（200）：
```json
{
  "total_questions": 10,
  "error_count": 4,
  "mastery_count": 3,
  "weak_count": 2,
  "predicted_score": 65.5,
  "formula_memory_rate": 0.75,
  "model_identify_rate": 0.60,
  "calculation_accuracy": 0.80,
  "reading_accuracy": 0.70
}
```
| 字段 | 类型 | 说明 |
|------|------|------|
| total_questions | int | 总题目数 |
| error_count | int | 错题数 |
| mastery_count | int | 已掌握知识点数 |
| weak_count | int | 薄弱知识点数 |
| predicted_score | float\|null | 预测分数 |
| formula_memory_rate | float | 公式记忆率（0-1） |
| model_identify_rate | float | 模型识别率（0-1） |
| calculation_accuracy | float | 计算准确率（0-1） |
| reading_accuracy | float | 审题准确率（0-1） |

- 错误码：`401/403` 未认证
- curl 示例：
```bash
curl http://8.130.16.212:8001/api/dashboard \
  -H "Authorization: Bearer <token>"
```
- 备注：四维能力值由上传题目时自动聚合计算
- 状态：✅ 完整实现

---

## 6. 推荐模块 Recommendations

### GET /api/recommendations

- 认证：✅ JWT
- 请求参数：无
- 响应（200）：
```json
[
  {
    "target_type": "model",
    "target_id": "model_coulomb_balance",
    "target_name": "库仑力平衡",
    "current_level": 2,
    "error_count": 3,
    "is_unstable": true
  }
]
```
| 字段 | 类型 | 说明 |
|------|------|------|
| target_type | string | 目标类型：`"model"` 或 `"knowledge"` |
| target_id | string | 目标 ID |
| target_name | string | 目标名称 |
| current_level | int | 当前掌握等级 |
| error_count | int | 错题数 |
| is_unstable | bool | 是否不稳定 |

- curl 示例：
```bash
curl http://8.130.16.212:8001/api/recommendations \
  -H "Authorization: Bearer <token>"
```
- 状态：✅ 完整实现

---

## 7. 知识点模块 Knowledge

### GET /api/knowledge/tree

- 认证：无
- 请求参数：无
- 响应（200）：
```json
[
  {
    "chapter": "力学",
    "sections": [
      {
        "section": "牛顿运动定律",
        "items": [
          {
            "id": "kp_newton_second",
            "name": "牛顿第二定律",
            "conclusion_level": 3,
            "description": "F=ma 的应用"
          }
        ]
      }
    ]
  }
]
```
- curl 示例：
```bash
curl http://8.130.16.212:8001/api/knowledge/tree
```
- 状态：✅ 完整实现

---

### GET /api/knowledge/{kp_id}

- 认证：✅ JWT
- 路径参数：

| 参数 | 类型 | 说明 |
|------|------|------|
| kp_id | string | 知识点 ID |

- 响应（200）：
```json
{
  "id": "kp_newton_second",
  "name": "牛顿第二定律",
  "conclusion_level": 3,
  "description": "F=ma 的应用",
  "chapter": "力学",
  "section": "牛顿运动定律",
  "related_model_ids": ["model_newton_app"],
  "mastery_level": 3,
  "mastery_value": 0.75,
  "error_count": 2,
  "correct_count": 5
}
```
- 错误码：`404` 知识点不存在
- curl 示例：
```bash
curl http://8.130.16.212:8001/api/knowledge/kp_newton_second \
  -H "Authorization: Bearer <token>"
```
- 状态：✅ 完整实现

---

## 8. 解题模型模块 Models

### GET /api/models/tree

- 认证：无
- 请求参数：无
- 响应（200）：
```json
[
  {
    "chapter": "力学",
    "sections": [
      {
        "section": "牛顿定律应用",
        "items": [
          {
            "id": "model_newton_app",
            "name": "牛顿定律应用模型",
            "description": "利用牛顿三定律解题"
          }
        ]
      }
    ]
  }
]
```
- curl 示例：
```bash
curl http://8.130.16.212:8001/api/models/tree
```
- 状态：✅ 完整实现

---

### GET /api/models/{model_id}

- 认证：✅ JWT
- 路径参数：

| 参数 | 类型 | 说明 |
|------|------|------|
| model_id | string | 解题模型 ID |

- 响应（200）：
```json
{
  "id": "model_newton_app",
  "name": "牛顿定律应用模型",
  "description": "利用牛顿三定律解题",
  "chapter": "力学",
  "section": "牛顿定律应用",
  "prerequisite_kp_ids": ["kp_newton_second"],
  "confusion_group_ids": ["model_energy_conservation"],
  "mastery_level": 3,
  "mastery_value": 0.80,
  "error_count": 1,
  "correct_count": 4
}
```
- 错误码：`404` 模型不存在
- curl 示例：
```bash
curl http://8.130.16.212:8001/api/models/model_newton_app \
  -H "Authorization: Bearer <token>"
```
- 状态：✅ 完整实现

---

## 9. 成绩预测 Prediction

### GET /api/prediction/score

- 认证：✅ JWT
- 请求参数：无
- 响应（200）：
```json
{
  "predicted_score": 65.5,
  "trend_data": [
    {"date": "2026-02-20", "score": 60.0},
    {"date": "2026-02-21", "score": 62.5},
    {"date": "2026-02-24", "score": 65.5}
  ],
  "priority_models": [
    {
      "model_id": "model_coulomb_balance",
      "model_name": "库仑力平衡",
      "current_level": 1,
      "error_count": 3
    }
  ],
  "score_path": [
    {"label": "公式记忆", "current": 0.75, "target": 0.90},
    {"label": "模型识别", "current": 0.60, "target": 0.85}
  ]
}
```
| 字段 | 类型 | 说明 |
|------|------|------|
| predicted_score | float\|null | 预测分数（avg(mastery)/100*target_score） |
| trend_data | list[TrendPoint] | 每日正确率折算的趋势数据 |
| priority_models | list[PriorityModel] | 优先提升的模型列表 |
| score_path | list[ScorePathRow] | 提分路径（当前 vs 目标） |

- curl 示例：
```bash
curl http://8.130.16.212:8001/api/prediction/score \
  -H "Authorization: Bearer <token>"
```
- 状态：✅ 完整实现

---

## 10. 周报 Weekly Review

### GET /api/weekly-review

- 认证：✅ JWT
- 请求参数：无
- 响应（200）：
```json
{
  "score_change": 2.5,
  "weekly_progress": {
    "total_questions": 15,
    "correct_count": 10,
    "error_count": 5,
    "new_mastered": 2
  },
  "dashboard_stats": {
    "total_questions": 50,
    "error_count": 20
  },
  "next_week_focus": ["kp_coulomb_law", "model_energy_conservation"]
}
```
| 字段 | 类型 | 说明 |
|------|------|------|
| score_change | float | 周间正确率对比变化 |
| weekly_progress | WeeklyProgress | 本周做题统计 |
| dashboard_stats | dict | 仪表盘快照 |
| next_week_focus | list[string] | 下周重点关注项 |

- curl 示例：
```bash
curl http://8.130.16.212:8001/api/weekly-review \
  -H "Authorization: Bearer <token>"
```
- 状态：✅ 完整实现

---

## 11. 考试模块 Exams

### GET /api/exams/recent

- 认证：✅ JWT
- 请求参数：无
- 响应（200）：
```json
[
  {
    "id": "exam_001",
    "name": "期中考试",
    "score": 85.0,
    "total_score": 150,
    "date": "2026-02-20"
  }
]
```
| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 考试 ID（由 Question 按日期聚合生成） |
| name | string | 考试名称 |
| score | float\|null | 得分 |
| total_score | float | 总分，默认 150 |
| date | string | 日期 |

- curl 示例：
```bash
curl http://8.130.16.212:8001/api/exams/recent \
  -H "Authorization: Bearer <token>"
```
- 备注：基于 Question 表按日期聚合，非独立考试表
- 状态：✅ 完整实现

---

### GET /api/exams/heatmap

- 认证：✅ JWT
- 请求参数：无
- 响应（200）：
```json
[
  {"date": "2026-02-20", "count": 5},
  {"date": "2026-02-21", "count": 3},
  {"date": "2026-02-24", "count": 8}
]
```
| 字段 | 类型 | 说明 |
|------|------|------|
| date | string | 日期 |
| count | int | 当日做题数 |

- curl 示例：
```bash
curl http://8.130.16.212:8001/api/exams/heatmap \
  -H "Authorization: Bearer <token>"
```
- 状态：✅ 完整实现

---

## 12. 闪卡模块 Flashcards

### GET /api/flashcards

- 认证：✅ JWT
- 请求参数：无
- 响应（200）：
```json
[
  {
    "id": "mastery_uuid",
    "target_type": "model",
    "target_id": "model_newton_app",
    "target_name": "牛顿定律应用",
    "mastery_value": 0.45,
    "due": true
  }
]
```
| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | Mastery 记录 ID |
| target_type | string | 目标类型：`"model"` 或 `"knowledge"` |
| target_id | string | 目标 ID |
| target_name | string | 目标名称 |
| mastery_value | float | 掌握度（0-1） |
| due | bool | 是否到期需要复习 |

- curl 示例：
```bash
curl http://8.130.16.212:8001/api/flashcards \
  -H "Authorization: Bearer <token>"
```
- 状态：✅ 完整实现

---

### POST /api/flashcards/{mastery_id}/review

- 认证：✅ JWT
- 路径参数：

| 参数 | 类型 | 说明 |
|------|------|------|
| mastery_id | string | Mastery 记录 ID |

- 请求体：
```json
{
  "quality": 4
}
```
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| quality | int | ✅ | SM-2 算法质量评分（0-5） |

- 响应（200）：
```json
{"ok": true}
```
- 错误码：`404` 闪卡不存在
- curl 示例：
```bash
curl -X POST http://8.130.16.212:8001/api/flashcards/<mastery_id>/review \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"quality": 4}'
```
- 状态：✅ 完整实现

---

## 13. AI 诊断会话 Diagnosis

### GET /api/diagnosis/session

- 认证：✅ JWT
- 请求参数：无
- 响应（200）：
```json
{
  "session_id": "",
  "status": "idle",
  "messages": []
}
```
| 字段 | 类型 | 说明 |
|------|------|------|
| session_id | string | 会话 ID（当前为空） |
| status | string | 会话状态，默认 `"idle"` |
| messages | list[DiagnosisMessage] | 对话消息列表（当前为空） |

DiagnosisMessage 结构：
```json
{"role": "user|assistant", "content": "消息内容"}
```

- curl 示例：
```bash
curl http://8.130.16.212:8001/api/diagnosis/session \
  -H "Authorization: Bearer <token>"
```
- 状态：🔧 Stub — 返回空初始结构，待接入 AI 对话逻辑

---

## 14. 知识学习会话 Learning

### GET /api/knowledge/learning/session

- 认证：✅ JWT
- 请求参数：无
- 响应（200）：
```json
{
  "knowledge_point_id": "",
  "knowledge_point_name": "",
  "current_step": 0,
  "dialogues": []
}
```
| 字段 | 类型 | 说明 |
|------|------|------|
| knowledge_point_id | string | 知识点 ID（当前为空） |
| knowledge_point_name | string | 知识点名称（当前为空） |
| current_step | int | 当前步骤，默认 0 |
| dialogues | list[LearningDialogue] | 对话列表（当前为空） |

LearningDialogue 结构：
```json
{"role": "user|assistant", "content": "消息内容"}
```

- curl 示例：
```bash
curl http://8.130.16.212:8001/api/knowledge/learning/session \
  -H "Authorization: Bearer <token>"
```
- 状态：🔧 Stub — 返回空初始结构，待接入知识学习对话逻辑

---

## 15. 模型训练会话 Training

### GET /api/models/training/session

- 认证：✅ JWT
- 请求参数：无
- 响应（200）：
```json
{
  "model_id": "",
  "model_name": "",
  "current_step": 0,
  "dialogues": []
}
```
| 字段 | 类型 | 说明 |
|------|------|------|
| model_id | string | 模型 ID（当前为空） |
| model_name | string | 模型名称（当前为空） |
| current_step | int | 当前步骤，默认 0 |
| dialogues | list[TrainingDialogue] | 对话列表（当前为空） |

TrainingDialogue 结构：
```json
{"role": "user|assistant", "content": "消息内容"}
```

- curl 示例：
```bash
curl http://8.130.16.212:8001/api/models/training/session \
  -H "Authorization: Bearer <token>"
```
- 状态：🔧 Stub — 返回空初始结构，待接入模型训练对话逻辑

---

## 附录：认证说明

所有标记 "✅ JWT" 的端点需要在请求头中携带 Bearer Token：

```
Authorization: Bearer <access_token>
```

Token 通过 `/api/auth/register` 或 `/api/auth/login` 获取。未携带或 Token 过期返回 `401/403`。

## 附录：端点汇总表

| # | Method | Path | 认证 | 状态 |
|---|--------|------|------|------|
| 1 | GET | `/health` | 无 | ✅ |
| 2 | POST | `/api/auth/register` | 无 | ✅ |
| 3 | POST | `/api/auth/login` | 无 | ✅ |
| 4 | GET | `/api/auth/me` | JWT | ✅ |
| 5 | POST | `/api/questions/upload` | JWT | ✅ |
| 6 | GET | `/api/questions/history` | JWT | ✅ |
| 7 | GET | `/api/questions/aggregate` | JWT | ✅ |
| 8 | GET | `/api/questions/{question_id}` | JWT | ✅ |
| 9 | POST | `/api/upload/image` | JWT | ✅ |
| 10 | GET | `/api/dashboard` | JWT | ✅ |
| 11 | GET | `/api/recommendations` | JWT | ✅ |
| 12 | GET | `/api/knowledge/tree` | 无 | ✅ |
| 13 | GET | `/api/knowledge/{kp_id}` | JWT | ✅ |
| 14 | GET | `/api/models/tree` | 无 | ✅ |
| 15 | GET | `/api/models/{model_id}` | JWT | ✅ |
| 16 | GET | `/api/prediction/score` | JWT | ✅ |
| 17 | GET | `/api/weekly-review` | JWT | ✅ |
| 18 | GET | `/api/exams/recent` | JWT | ✅ |
| 19 | GET | `/api/exams/heatmap` | JWT | ✅ |
| 20 | GET | `/api/flashcards` | JWT | ✅ |
| 21 | POST | `/api/flashcards/{mastery_id}/review` | JWT | ✅ |
| 22 | GET | `/api/diagnosis/session` | JWT | 🔧 |
| 23 | GET | `/api/knowledge/learning/session` | JWT | 🔧 |
| 24 | GET | `/api/models/training/session` | JWT | 🔧 |
