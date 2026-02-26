# EchoMind API 参考文档

> 基址：`http://8.130.16.212:8001`
> 认证方式：Bearer Token（JWT），在 `Authorization` 头中传递
> 生成时间：2026-02-26（更新）
> 端点总数：41（含 1 个健康检查 + 40 个完整实现）

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
| 13 | [AI 诊断 Diagnosis](#13-ai-诊断会话-diagnosis) | 5 | ✅ |
| 14 | [知识学习 Learning](#14-知识学习会话-learning) | 5 | ✅ |
| 15 | [模型训练 Training](#15-模型训练会话-training) | 6 | ✅ |
| 16 | [卷面策略 Strategy](#16-卷面策略-strategy) | 4 | ✅ |

> ✅ = 完整实现

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
  "target_score": 90.0,
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
| target_score | float | 学生目标分数，来自 students.target_score |
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
    "formula_memory_rate": 0.75,
    "model_identify_rate": 0.60,
    "calculation_accuracy": 0.80,
    "reading_accuracy": 0.70
  },
  "next_week_focus": ["kp_coulomb_law", "model_energy_conservation"],
  "last_week_score": 60.0,
  "this_week_score": 62.5,
  "progress_items": ["牛顿第二定律", "动量守恒"],
  "focus_item_names": ["库仑定律", "能量守恒"]
}
```
| 字段 | 类型 | 说明 |
|------|------|------|
| score_change | float | 周间正确率变化值（正数=提升，负数=下降） |
| weekly_progress | WeeklyProgress | 本周做题统计 |
| dashboard_stats | dict | 仪表盘快照（四维能力值） |
| next_week_focus | list[string] | 下周重点关注的知识点/模型 ID 列表 |
| last_week_score | float | 上周预测分（正确率×150） |
| this_week_score | float | 本周预测分（正确率×150） |
| progress_items | list[string] | 本周新掌握的知识点/模型名称列表 |
| focus_item_names | list[string] | 下周重点的知识点/模型名称列表 |

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

> 5 个端点，全部 JWT 鉴权。通过多轮对话诊断学生错题的错误根源（最多 5 轮）。

### POST /api/diagnosis/start

创建诊断会话，绑定到一道错题，AI 生成开场白。

- 认证：✅ JWT
- 请求体：
```json
{
  "question_id": "uuid-of-the-question"
}
```
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| question_id | string (UUID) | ✅ | 要诊断的错题 ID |

- 响应（201）：
```json
{
  "session_id": "uuid",
  "status": "active",
  "question_id": "uuid",
  "round": 1,
  "max_rounds": 5,
  "messages": [
    {
      "id": "uuid",
      "role": "assistant",
      "content": "我来帮你分析这道题...",
      "round": 1,
      "created_at": "2026-02-25T06:00:00Z"
    }
  ]
}
```
- 错误码：`404` 题目不存在或不属于当前用户
- 备注：同一题同一时间只允许一个活跃会话，重复调用返回已有会话
- curl 示例：
```bash
curl -X POST http://8.130.16.212:8001/api/diagnosis/start \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"question_id":"<question_uuid>"}'
```
- 状态：✅ 完整实现

---

### POST /api/diagnosis/chat

学生发送消息，获取 AI 诊断回复。最后一轮会包含诊断结论（5W JSON）。

- 认证：✅ JWT
- 请求体：
```json
{
  "session_id": "uuid",
  "content": "我觉得应该用动量守恒"
}
```
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| session_id | string (UUID) | ✅ | 诊断会话 ID |
| content | string | ✅ | 学生发送的消息文本 |

- 响应（200）：
```json
{
  "message": {
    "id": "uuid",
    "role": "assistant",
    "content": "你说的对，那这道题有几个过程？",
    "round": 2,
    "created_at": "2026-02-25T06:01:00Z"
  },
  "session": {
    "session_id": "uuid",
    "status": "active",
    "round": 2,
    "max_rounds": 5
  }
}
```

诊断完成时额外包含 `diagnosis_result`：
```json
{
  "message": { "..." },
  "session": { "status": "completed", "..." },
  "diagnosis_result": {
    "four_layer": {
      "modeling": "pass",
      "equation": "fail",
      "execution": "unreached",
      "bottleneck_layer": "equation",
      "bottleneck_detail": "公式选择错误"
    },
    "root_category": "model_application",
    "root_subcategory": "decide",
    "evidence_5w": {
      "what_description": "选错了公式",
      "when_stage": "select",
      "root_cause_id": "model_xxx",
      "ai_explanation": "...",
      "confidence": "confirmed"
    },
    "next_action": {
      "type": "model_training",
      "target_id": "model_xxx",
      "message": "建议进行模型训练"
    }
  }
}
```
- 错误码：`404` 会话不存在，`400` 会话已结束或已达最大轮次
- curl 示例：
```bash
curl -X POST http://8.130.16.212:8001/api/diagnosis/chat \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"session_id":"<session_uuid>","content":"我觉得应该用动量守恒"}'
```
- 状态：✅ 完整实现

---

### GET /api/diagnosis/session

获取当前用户最近的活跃诊断会话。无活跃会话时返回 `null`。

- 认证：✅ JWT
- 请求参数：无
- 响应（200）：与 `GET /api/diagnosis/session/{session_id}` 相同，或 `null`
- curl 示例：
```bash
curl http://8.130.16.212:8001/api/diagnosis/session \
  -H "Authorization: Bearer <token>"
```
- 状态：✅ 完整实现

---

### GET /api/diagnosis/session/{session_id}

获取指定诊断会话详情，含完整消息历史。

- 认证：✅ JWT
- 路径参数：

| 参数 | 类型 | 说明 |
|------|------|------|
| session_id | string (UUID) | 诊断会话 ID |

- 响应（200）：
```json
{
  "session_id": "uuid",
  "question_id": "uuid",
  "status": "active | completed | expired",
  "round": 3,
  "max_rounds": 5,
  "diagnosis_result": null,
  "messages": [
    {
      "id": "uuid",
      "role": "assistant",
      "content": "...",
      "round": 1,
      "created_at": "2026-02-25T06:00:00Z"
    }
  ],
  "created_at": "2026-02-25T06:00:00Z"
}
```

DiagnosisMessage 结构：

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string (UUID) | 消息唯一 ID |
| role | string | 消息角色：`user` / `assistant` / `system` |
| content | string | 消息文本内容 |
| round | int | 所属对话轮次（从 1 开始） |
| created_at | string | 消息创建时间 (ISO 8601) |

- 错误码：`404` 会话不存在
- curl 示例：
```bash
curl http://8.130.16.212:8001/api/diagnosis/session/<session_id> \
  -H "Authorization: Bearer <token>"
```
- 状态：✅ 完整实现

---

### POST /api/diagnosis/complete

手动结束诊断会话（学生主动退出时调用）。将会话状态设为 `expired`，不生成诊断结论。

- 认证：✅ JWT
- 请求体：
```json
{
  "session_id": "uuid"
}
```
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| session_id | string (UUID) | ✅ | 要结束的诊断会话 ID |

- 响应（200）：
```json
{
  "session_id": "uuid",
  "status": "expired",
  "message": "诊断会话已手动结束"
}
```
- 错误码：`404` 会话不存在，`400` 会话已结束
- curl 示例：
```bash
curl -X POST http://8.130.16.212:8001/api/diagnosis/complete \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"session_id":"<session_uuid>"}'
```
- 状态：✅ 完整实现

---

## 14. 知识学习会话 Learning

> 5 个端点，全部 JWT 鉴权。通过五步 AI 引导工作流帮助学生学习知识点概念。

### POST /api/knowledge/learning/start

创建学习会话，绑定到一个知识点，AI 生成开场白。

- 认证：✅ JWT
- 请求体：
```json
{
  "knowledge_point_id": "kp_newton_second",
  "source": "self_study"
}
```
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| knowledge_point_id | string | ✅ | 知识点 ID |
| source | string | ❌ | 来源路径，默认 `"self_study"`，可选 `"diagnosis_redirect"` / `"model_training"` / `"weekly_review"` |

- 响应（201）：
```json
{
  "session_id": "uuid",
  "status": "active",
  "knowledge_point_id": "kp_newton_second",
  "knowledge_point_name": "牛顿第二定律",
  "current_step": 1,
  "max_steps": 5,
  "mastery_level": "L1",
  "mastery_value": 15,
  "messages": [
    {
      "id": "uuid",
      "role": "assistant",
      "content": "我们来学习「牛顿第二定律」...",
      "step": 1,
      "created_at": "2026-02-26T06:00:00Z"
    }
  ]
}
```
- 错误码：`404` 知识点不存在
- 备注：同一知识点同一时间只允许一个活跃会话，重复调用返回已有会话
- curl 示例：
```bash
curl -X POST http://8.130.16.212:8001/api/knowledge/learning/start \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"knowledge_point_id":"kp_newton_second","source":"self_study"}'
```
- 状态：✅ 完整实现

---

### POST /api/knowledge/learning/chat

学生发送消息，获取 AI 回复。AI 根据当前 Step 决定回复策略，自动推进步骤。

- 认证：✅ JWT
- 请求体：
```json
{
  "session_id": "uuid",
  "content": "电荷量就是电荷的多少吧"
}
```
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| session_id | string (UUID) | ✅ | 学习会话 ID |
| content | string | ✅ | 学生发送的消息文本 |

- 响应（200）：
```json
{
  "message": {
    "id": "uuid",
    "role": "assistant",
    "content": "对的！那你知道它的单位是什么吗？",
    "step": 2,
    "created_at": "2026-02-26T06:01:00Z"
  },
  "session": {
    "session_id": "uuid",
    "status": "active",
    "current_step": 2
  }
}
```
- 错误码：`404` 会话不存在，`400` 会话已结束
- curl 示例：
```bash
curl -X POST http://8.130.16.212:8001/api/knowledge/learning/chat \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"session_id":"<session_uuid>","content":"电荷量就是电荷的多少吧"}'
```
- 状态：✅ 完整实现

---

### GET /api/knowledge/learning/session

获取当前用户最近的活跃学习会话（兼容旧前端）。无活跃会话时返回空结构。

- 认证：✅ JWT
- 请求参数：无
- 响应（200）：
```json
{
  "knowledge_point_id": "kp_newton_second",
  "knowledge_point_name": "牛顿第二定律",
  "current_step": 2,
  "dialogues": [
    {"role": "assistant", "content": "我们来学习..."},
    {"role": "user", "content": "好的"}
  ]
}
```
- curl 示例：
```bash
curl http://8.130.16.212:8001/api/knowledge/learning/session \
  -H "Authorization: Bearer <token>"
```
- 状态：✅ 完整实现

---

### GET /api/knowledge/learning/session/{session_id}

获取指定学习会话详情，含完整消息历史。

- 认证：✅ JWT
- 路径参数：

| 参数 | 类型 | 说明 |
|------|------|------|
| session_id | string (UUID) | 学习会话 ID |

- 响应（200）：
```json
{
  "session_id": "uuid",
  "status": "active | completed | expired",
  "knowledge_point_id": "kp_newton_second",
  "knowledge_point_name": "",
  "current_step": 3,
  "max_steps": 5,
  "source": "self_study",
  "mastery_before": 15,
  "mastery_after": null,
  "messages": [
    {
      "id": "uuid",
      "role": "assistant",
      "content": "...",
      "step": 1,
      "created_at": "2026-02-26T06:00:00Z"
    }
  ],
  "created_at": "2026-02-26T06:00:00Z",
  "updated_at": "2026-02-26T06:01:00Z"
}
```
- 错误码：`404` 会话不存在
- curl 示例：
```bash
curl http://8.130.16.212:8001/api/knowledge/learning/session/<session_id> \
  -H "Authorization: Bearer <token>"
```
- 状态：✅ 完整实现

---

### POST /api/knowledge/learning/complete

手动结束学习会话（学生主动退出时调用）。将会话状态设为 `expired`，不更新掌握度。

- 认证：✅ JWT
- 请求体：
```json
{
  "session_id": "uuid"
}
```
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| session_id | string (UUID) | ✅ | 要结束的学习会话 ID |

- 响应（200）：
```json
{
  "session_id": "uuid",
  "status": "expired",
  "message": "学习会话已手动结束"
}
```
- 错误码：`404` 会话不存在，`400` 会话已结束
- curl 示例：
```bash
curl -X POST http://8.130.16.212:8001/api/knowledge/learning/complete \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"session_id":"<session_uuid>"}'
```
- 状态：✅ 完整实现

---

## 15. 模型训练会话 Training

> 6 个端点，全部 JWT 鉴权。通过六步专项训练帮助学生突破模型应用瓶颈层。

### POST /api/models/training/start

创建训练会话，路由层自动判定入口 Step（Level 即入口）。

- 认证：✅ JWT
- 请求体：
```json
{
  "model_id": "uuid-of-the-model",
  "source": "error_diagnosis | self_study | quick_check | recommendation",
  "question_id": "uuid（可选，来自错题诊断时传入）",
  "diagnosis_result": {
    "error_subtype": "identify | decide | step | subject | substitution"
  }
}
```
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| model_id | string (UUID) | ✅ | 要训练的解题模型 ID |
| source | string | ❌ | 来源路径，默认 `"self_study"` |
| question_id | string (UUID) | ❌ | 来源错题 ID（诊断跳转时传入） |
| diagnosis_result | object | ❌ | 诊断结果（含 error_subtype） |

- 响应（201）：
```json
{
  "session_id": "uuid",
  "model_id": "uuid",
  "model_name": "牛顿第二定律-连接体",
  "status": "active",
  "current_step": 1,
  "entry_step": 1,
  "source": "error_diagnosis",
  "mastery": {
    "current_level": 1,
    "peak_level": 3,
    "mastery_value": 15.0
  },
  "messages": [
    {
      "id": "uuid",
      "role": "assistant",
      "content": "我们来训练这个模型。首先看这道题...",
      "step": 1,
      "created_at": "2026-02-26T06:00:00Z"
    }
  ]
}
```
- 错误码：`404` 模型不存在，`409` 已有活跃训练会话
- 备注：同一模型同一时间只允许一个活跃会话
- curl 示例：
```bash
curl -X POST http://8.130.16.212:8001/api/models/training/start \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"model_id":"<model_uuid>","source":"self_study"}'
```
- 状态：✅ 完整实现

---

### POST /api/models/training/interact

步内交互：学生发送回答，获取 AI 回复和判定结果。

- 认证：✅ JWT
- 请求体：
```json
{
  "session_id": "uuid",
  "content": "我觉得应该用动量守恒定律"
}
```
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| session_id | string (UUID) | ✅ | 训练会话 ID |
| content | string | ✅ | 学生发送的消息文本 |

- 响应（200）：
```json
{
  "message": {
    "id": "uuid",
    "role": "assistant",
    "content": "不错，你选对了模型。那这道题有几个过程？",
    "step": 1,
    "created_at": "2026-02-26T06:01:00Z"
  },
  "step_status": "in_progress",
  "session": {
    "session_id": "uuid",
    "status": "active",
    "current_step": 1
  }
}
```

当步骤完成时，响应额外包含 `step_result` 和 `next_step_hint`：
```json
{
  "message": { "..." },
  "step_status": "completed",
  "step_result": {
    "step": 1,
    "passed": true,
    "ai_summary": "你成功识别了动量守恒模型，过程拆分也正确"
  },
  "next_step_hint": {
    "next_step": 2,
    "step_name": "决策（公式选择）",
    "auto_advance": false
  },
  "session": { "..." }
}
```
- 错误码：`404` 会话不存在，`400` 会话已结束
- curl 示例：
```bash
curl -X POST http://8.130.16.212:8001/api/models/training/interact \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"session_id":"<session_uuid>","content":"我觉得应该用动量守恒定律"}'
```
- 状态：✅ 完整实现

---

### POST /api/models/training/next-step

完成当前步骤，进入下一步。前端在收到 `step_status: "completed"` 后调用。

- 认证：✅ JWT
- 请求体：
```json
{
  "session_id": "uuid"
}
```
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| session_id | string (UUID) | ✅ | 训练会话 ID |

- 响应（200）：
```json
{
  "session": {
    "session_id": "uuid",
    "status": "active",
    "current_step": 2,
    "previous_step": 1
  },
  "step_info": {
    "step": 2,
    "step_name": "决策（公式选择）"
  },
  "messages": [
    {
      "id": "uuid",
      "role": "assistant",
      "content": "很好，模型识别正确。现在来看公式选择...",
      "step": 2,
      "created_at": "2026-02-26T06:02:00Z"
    }
  ]
}
```

训练完成时的响应：
```json
{
  "session": {
    "session_id": "uuid",
    "status": "completed",
    "current_step": 6
  },
  "training_result": {
    "steps_completed": [1, 2, 3, 4, 5, 6],
    "steps_passed": [1, 2, 3, 4, 5, 6],
    "mastery_update": {
      "previous_level": 1,
      "new_level": 4,
      "previous_value": 15.0,
      "new_value": 65.0
    },
    "ai_summary": "你已经完成了动量守恒模型的全流程训练，掌握度从L1提升到L4"
  }
}
```
- 错误码：`404` 会话不存在，`400` 当前步骤未完成
- curl 示例：
```bash
curl -X POST http://8.130.16.212:8001/api/models/training/next-step \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"session_id":"<session_uuid>"}'
```
- 状态：✅ 完整实现

---

### GET /api/models/training/session/{session_id}

获取指定训练会话详情（含消息历史 + 步骤结果）。

- 认证：✅ JWT
- 路径参数：

| 参数 | 类型 | 说明 |
|------|------|------|
| session_id | string (UUID) | 训练会话 ID |

- 响应（200）：
```json
{
  "session_id": "uuid",
  "model_id": "uuid",
  "model_name": "牛顿第二定律-连接体",
  "status": "active | completed | expired",
  "current_step": 3,
  "entry_step": 1,
  "source": "error_diagnosis",
  "step_results": [
    {"step": 1, "passed": true, "ai_summary": "模型识别正确"},
    {"step": 2, "passed": true, "ai_summary": "公式选择正确"}
  ],
  "messages": [
    {"id": "uuid", "role": "assistant", "content": "...", "step": 1, "created_at": "..."},
    {"id": "uuid", "role": "user", "content": "...", "step": 1, "created_at": "..."}
  ],
  "created_at": "2026-02-26T06:00:00Z"
}
```
- 错误码：`404` 会话不存在
- curl 示例：
```bash
curl http://8.130.16.212:8001/api/models/training/session/<session_id> \
  -H "Authorization: Bearer <token>"
```
- 状态：✅ 完整实现

---

### GET /api/models/training/session

获取当前用户最近的活跃训练会话。无活跃会话时返回 `null`。

- 认证：✅ JWT
- 请求参数：无
- 响应（200）：与 `GET /api/models/training/session/{session_id}` 相同，或 `null`
- curl 示例：
```bash
curl http://8.130.16.212:8001/api/models/training/session \
  -H "Authorization: Bearer <token>"
```
- 状态：✅ 完整实现

---

### POST /api/models/training/complete

手动结束训练会话（学生主动退出时调用）。将会话状态设为 `expired`，不更新掌握度。已完成的步骤结果保留。

- 认证：✅ JWT
- 请求体：
```json
{
  "session_id": "uuid"
}
```
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| session_id | string (UUID) | ✅ | 要结束的训练会话 ID |

- 响应（200）：
```json
{
  "session_id": "uuid",
  "status": "expired",
  "message": "训练会话已手动结束"
}
```
- 错误码：`404` 会话不存在，`400` 会话已结束
- curl 示例：
```bash
curl -X POST http://8.130.16.212:8001/api/models/training/complete \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"session_id":"<session_uuid>"}'
```
- 状态：✅ 完整实现

---

## 16. 卷面策略 Strategy

### POST /api/strategy/generate

- 认证：✅ JWT
- 请求体：
```json
{
  "target_score": 70
}
```
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| target_score | int | ❌ | 目标分数（不传则使用学生当前 target_score） |

- 响应（200）：
```json
{
  "target_score": 70,
  "total_score": 100,
  "region_id": "tianjin",
  "subject": "physics",
  "key_message": "70分=选择题最多错2个+大题前两道拿满，你做得到",
  "question_strategies": [
    {
      "question_range": "选择1-6（单选）",
      "max_score": 18,
      "target_score": 18,
      "attitude": "must",
      "note": "全对",
      "display_text": "这些你绝对能做到"
    }
  ],
  "exam_structure": ["..."],
  "diagnosis_path": ["..."]
}
```
- 错误码：`404` 未找到匹配的地区模板，`400` target_score 超出范围
- curl 示例：
```bash
curl -X POST http://8.130.16.212:8001/api/strategy/generate \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"target_score": 70}'
```
- 状态：✅ 完整实现

---

### GET /api/strategy

- 认证：✅ JWT
- 请求参数：无
- 响应（200）：
```json
{
  "has_strategy": true,
  "strategy": {
    "target_score": 70,
    "total_score": 100,
    "region_id": "tianjin",
    "subject": "physics",
    "key_message": "70分=选择题最多错2个+大题前两道拿满，你做得到",
    "question_strategies": ["..."],
    "exam_structure": ["..."],
    "diagnosis_path": ["..."],
    "generated_at": "2026-02-26T06:00:00Z"
  }
}
```
| 字段 | 类型 | 说明 |
|------|------|------|
| has_strategy | bool | 是否已生成策略 |
| strategy | StrategyData\|null | 策略数据，未生成时为 null |

- curl 示例：
```bash
curl http://8.130.16.212:8001/api/strategy \
  -H "Authorization: Bearer <token>"
```
- 状态：✅ 完整实现

---

### PUT /api/strategy/target-score

- 认证：✅ JWT
- 请求体：
```json
{
  "new_target_score": 80
}
```
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| new_target_score | int | ✅ | 新目标分数（30-150） |

- 响应（200）：
```json
{
  "old_target_score": 70,
  "new_target_score": 80,
  "strategy": { "..." },
  "changes": {
    "upgraded_to_must": [
      {
        "question_range": "选择7-8（多选）",
        "old_attitude": "try",
        "new_attitude": "must"
      }
    ],
    "downgraded": [],
    "key_message_diff": "从70分到80分，你还需要额外稳住选择第7-8题"
  }
}
```
- 错误码：`400` 分数超出范围，`404` 无匹配模板
- curl 示例：
```bash
curl -X PUT http://8.130.16.212:8001/api/strategy/target-score \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"new_target_score": 80}'
```
- 状态：✅ 完整实现

---

### GET /api/strategy/templates

- 认证：✅ JWT
- 请求参数：无
- 响应（200）：
```json
{
  "region_id": "tianjin",
  "subject": "physics",
  "available_scores": [60, 70, 80, 90, 100]
}
```
| 字段 | 类型 | 说明 |
|------|------|------|
| region_id | string | 当前用户地区 |
| subject | string | 当前用户科目 |
| available_scores | list[int] | 可用的分数档列表 |

- curl 示例：
```bash
curl http://8.130.16.212:8001/api/strategy/templates \
  -H "Authorization: Bearer <token>"
```
- 状态：✅ 完整实现

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
| 22 | POST | `/api/diagnosis/start` | JWT | ✅ |
| 23 | POST | `/api/diagnosis/chat` | JWT | ✅ |
| 24 | GET | `/api/diagnosis/session` | JWT | ✅ |
| 25 | GET | `/api/diagnosis/session/{session_id}` | JWT | ✅ |
| 26 | POST | `/api/diagnosis/complete` | JWT | ✅ |
| 27 | POST | `/api/knowledge/learning/start` | JWT | ✅ |
| 28 | POST | `/api/knowledge/learning/chat` | JWT | ✅ |
| 29 | GET | `/api/knowledge/learning/session` | JWT | ✅ |
| 30 | GET | `/api/knowledge/learning/session/{session_id}` | JWT | ✅ |
| 31 | POST | `/api/knowledge/learning/complete` | JWT | ✅ |
| 32 | POST | `/api/models/training/start` | JWT | ✅ |
| 33 | POST | `/api/models/training/interact` | JWT | ✅ |
| 34 | POST | `/api/models/training/next-step` | JWT | ✅ |
| 35 | GET | `/api/models/training/session/{session_id}` | JWT | ✅ |
| 36 | GET | `/api/models/training/session` | JWT | ✅ |
| 37 | POST | `/api/models/training/complete` | JWT | ✅ |
| 38 | POST | `/api/strategy/generate` | JWT | ✅ |
| 39 | GET | `/api/strategy` | JWT | ✅ |
| 40 | PUT | `/api/strategy/target-score` | JWT | ✅ |
| 41 | GET | `/api/strategy/templates` | JWT | ✅ |
