# 注册策略（卷面策略）功能实现设计文档

> 创建日期：2026-02-26
> 状态：设计阶段，待用户审批
> 作者：claude-4 (peer)
> 依据：v1.0.md（Section 十四：注册流程、Section 四十六：地区卷面结构模板）、architecture.md

---

## 一、概述

### 1.1 功能定位

注册策略（卷面策略）是 EchoMind 注册流程的 Step 2，也是贯穿整个产品的核心数据基础。学生输入目标裸分后，系统根据**地区卷面结构模板**（教研预设）自动生成个性化的卷面策略，告诉学生每道题该拿多少分、哪些必须拿满、哪些可以放弃。

| 核心价值 | 说明 |
|---------|------|
| 目标可视化 | 将抽象的"考XX分"转化为具体的"每道题拿多少分" |
| 策略指导 | 🔴必须拿满 / 🟡争取拿分 / ⚪可放弃，一目了然 |
| 驱动下游 | AI 诊断、推荐排序、周报分析都依赖卷面策略数据 |
| 零成本 | 纯规则计算，不调用 LLM，0 API 成本 |

### 1.2 策略态度分类

| 态度 | 标识 | 含义 | 视觉 |
|------|------|------|------|
| 必须拿满 | 🔴 `must` | 与目标分直接挂钩的基础题 | 红色 |
| 争取拿分 | 🟡 `try` | 中等难度，争取部分得分 | 黄色 |
| 可放弃 | ⚪ `skip` | 超出目标分所需的难题 | 灰色 |

### 1.3 设计约束（来自产品规格）

- 纯规则系统，不调用 AI，0 成本
- 策略基于教研人工设计的地区模板（`regional_templates` 表）
- 每个"城市+科目+分数档"对应一份完整模板
- V1 先做天津物理作为示例，其他城市教研参照填充
- 目标分数变更时策略自动重新生成
- 策略展示是核心转化页面，需要家长也能看懂
- 100 分档也有特殊设计（不要求全部满分）

---

## 二、系统架构设计

### 2.1 整体数据流

```
┌─────────────┐                                    ┌──────────────┐
│  Flutter App │     POST /api/strategy/generate    │  FastAPI      │
│  (Riverpod)  │ ──────────────────────────────────→│  Router       │
│              │     {target_score}                  │  /strategy    │
│              │                                     │               │
│              │     GET /api/strategy               │               │
│              │ ──────────────────────────────────→ │               │
│              │                                     └───────┬───────┘
│              │     JSON response                           │
│              │ ←──────────────────────────────────          │
│              │     {exam_strategy}                  ┌───────▼───────┐
└─────────────┘                                     │ StrategyService │
                                                    │               │
                                                    │ 1. 查模板      │
                                                    │ 2. 匹配分数档  │
                                                    │ 3. 生成策略    │
                                                    │ 4. 写入学生    │
                                                    └───────┬───────┘
                                                            │
                                              ┌─────────────┼─────────────┐
                                              ▼                           ▼
                                       ┌───────────┐              ┌───────────┐
                                       │ PostgreSQL │              │ PostgreSQL │
                                       │ students   │              │ regional_  │
                                       │ .exam_     │              │ templates  │
                                       │  strategy  │              │            │
                                       └───────────┘              └───────────┘
```

### 2.2 核心组件

| 组件 | 职责 | 位置 |
|------|------|------|
| StrategyRouter | HTTP 端点，请求校验，JWT 鉴权 | `app/routers/strategy.py`（新建） |
| StrategyService | 业务逻辑：模板匹配、策略生成、分数档映射 | `app/services/strategy_service.py`（新建） |
| RegionalTemplate (ORM) | 地区模板持久化模型 | `app/models/regional_template.py`（已有） |
| Student (ORM) | 学生信息，含 `exam_strategy` JSONB 字段 | `app/models/student.py`（已有） |

---

## 三、API 端点设计

### 3.1 端点总览

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| POST | `/api/strategy/generate` | 生成/重新生成卷面策略 | JWT |
| GET | `/api/strategy` | 获取当前用户的卷面策略 | JWT |
| PUT | `/api/strategy/target-score` | 修改目标分数并重新生成策略 | JWT |
| GET | `/api/strategy/templates` | 获取可用的地区模板列表（调试用） | JWT |

### 3.2 端点详细定义

#### POST `/api/strategy/generate`

根据学生的 region_id、subject、target_score 查找匹配的地区模板，生成卷面策略并写入 `students.exam_strategy`。

**请求体：**
```json
{
  "target_score": 70
}
```
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| target_score | int | ❌ | 目标分数（不传则使用学生当前 target_score） |

**响应（200）：**
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
    },
    {
      "question_range": "选择7-8（多选）",
      "max_score": 6,
      "target_score": 3,
      "attitude": "try",
      "note": "稳选一半",
      "display_text": "多选题稳选一半"
    }
  ],
  "exam_structure": [
    {
      "section_name": "选择题",
      "questions": [
        {
          "question_number": 1,
          "max_score": 3,
          "difficulty": "easy",
          "typical_models": ["model_newton_app"],
          "typical_kps": ["kp_newton_second"]
        }
      ]
    }
  ],
  "diagnosis_path": [
    {
      "tier": 1,
      "model_id": "model_block_motion",
      "score_impact": "12-18分",
      "reason": "大题第一/二题核心",
      "skippable": false
    }
  ]
}
```

**逻辑：**
1. 从 JWT 获取当前用户的 region_id、subject
2. 如果传了 target_score，更新 `students.target_score`
3. 查找匹配的 `regional_templates`（精确匹配或最近分数档）
4. 如果找不到模板，返回 404 + 提示信息
5. 将模板中的 question_strategies / exam_structure / diagnosis_path 组装为 exam_strategy JSON
6. 写入 `students.exam_strategy`
7. 返回完整策略数据

**错误码：**
- `404`：未找到匹配的地区模板
- `400`：target_score 超出合理范围（30-150）

#### GET `/api/strategy`

获取当前用户的卷面策略。如果尚未生成，返回 `null`。

**请求参数：** 无

**响应（200）：**
```json
{
  "has_strategy": true,
  "strategy": {
    "target_score": 70,
    "total_score": 100,
    "region_id": "tianjin",
    "subject": "physics",
    "key_message": "70分=选择题最多错2个+大题前两道拿满，你做得到",
    "question_strategies": [ "..." ],
    "exam_structure": [ "..." ],
    "diagnosis_path": [ "..." ],
    "generated_at": "2026-02-26T06:00:00Z"
  }
}
```

**无策略时响应（200）：**
```json
{
  "has_strategy": false,
  "strategy": null
}
```

**逻辑：**
1. 从 JWT 获取当前用户
2. 读取 `students.exam_strategy` JSONB 字段
3. 如果为 null，返回 `has_strategy: false`
4. 否则返回完整策略数据

#### PUT `/api/strategy/target-score`

修改目标分数，自动重新生成卷面策略，并返回新旧策略对比。

**请求体：**
```json
{
  "new_target_score": 80
}
```
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| new_target_score | int | ✅ | 新目标分数（30-150） |

**响应（200）：**
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
        "new_attitude": "must",
        "related_models": ["model_multi_select"]
      }
    ],
    "downgraded": [],
    "key_message_diff": "从70分到80分，你还需要额外稳住选择第7-8题和大题第2题第3问"
  }
}
```

**逻辑：**
1. 校验 new_target_score 范围
2. 保存旧策略快照
3. 更新 `students.target_score`
4. 调用 `StrategyService.generate()` 生成新策略
5. 对比新旧策略，计算 `changes`（哪些题态度升级/降级）
6. 写入新策略到 `students.exam_strategy`
7. 返回新策略 + 变更摘要

#### GET `/api/strategy/templates`

获取当前用户所在地区可用的模板列表（调试/管理用途）。

**请求参数：** 无

**响应（200）：**
```json
{
  "region_id": "tianjin",
  "subject": "physics",
  "available_scores": [60, 70, 80, 90, 100],
  "templates": [
    {
      "target_score": 70,
      "total_score": 100,
      "key_message": "70分=选择题最多错2个+大题前两道拿满"
    }
  ]
}
```

**逻辑：**
1. 从 JWT 获取当前用户的 region_id、subject
2. 查询 `regional_templates` 中匹配的所有模板
3. 返回摘要列表（不含完整 exam_structure）

---

## 四、数据库 Schema

### 4.1 现有表：`regional_templates`（无需改动）

```sql
-- 已存在，无需迁移
CREATE TABLE regional_templates (
    id              VARCHAR(50) PRIMARY KEY,
    region_id       VARCHAR(30) NOT NULL,
    subject         VARCHAR(20) NOT NULL,
    target_score    INTEGER NOT NULL,
    total_score     INTEGER NOT NULL,
    exam_structure  JSONB NOT NULL,       -- 卷面结构定义
    question_strategies JSONB NOT NULL,   -- 分数档卷面策略
    diagnosis_path  JSONB NOT NULL,       -- 诊断路径（教研排序）
    created_at      TIMESTAMPTZ DEFAULT now(),
    UNIQUE (region_id, subject, target_score)
);
```

### 4.2 现有表：`students`（无需改动）

关键字段已存在：

```sql
-- students 表中已有字段，无需迁移
target_score    INTEGER NOT NULL,        -- 目标裸分
exam_strategy   JSONB,                   -- 卷面策略（本功能写入）
region_id       VARCHAR(30) NOT NULL,    -- 地区
subject         VARCHAR(20) NOT NULL     -- 科目
```

### 4.3 `students.exam_strategy` JSONB 结构定义

```json
{
  "target_score": 70,
  "total_score": 100,
  "region_id": "tianjin",
  "subject": "physics",
  "template_id": "tianjin_physics_70",
  "key_message": "70分=选择题最多错2个+大题前两道拿满，你做得到",
  "vs_lower": "比60分多要求：大题第一题全拿+选择多对2道",
  "vs_higher": "比80分允许放弃：大题第三题、多选最后一道",
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
  "exam_structure": [
    {
      "section_name": "选择题",
      "questions": [
        {
          "question_number": 1,
          "max_score": 3,
          "difficulty": "easy",
          "typical_models": ["model_newton_app"],
          "typical_kps": ["kp_newton_second"]
        }
      ]
    }
  ],
  "diagnosis_path": [
    {
      "tier": 1,
      "model_id": "model_block_motion",
      "score_impact": "12-18分",
      "reason": "大题第一/二题核心",
      "skippable": false
    }
  ],
  "generated_at": "2026-02-26T06:00:00Z"
}
```

### 4.4 新增表：`regional_templates` 需补充字段

现有模型缺少产品规格中的 `key_message`、`vs_lower`、`vs_higher` 字段。需要 Alembic 迁移：

```sql
ALTER TABLE regional_templates
    ADD COLUMN key_message TEXT,
    ADD COLUMN vs_lower TEXT,
    ADD COLUMN vs_higher TEXT;
```

### 4.5 ORM 模型变更

```python
# app/models/regional_template.py — 新增 3 个字段
class RegionalTemplate(Base):
    __tablename__ = "regional_templates"
    # ... 现有字段 ...
    key_message: Mapped[str | None] = mapped_column(Text)
    vs_lower: Mapped[str | None] = mapped_column(Text)
    vs_higher: Mapped[str | None] = mapped_column(Text)
```

### 4.6 Alembic 迁移

新增一个迁移文件，命名：`add_regional_template_message_fields`

---

## 五、策略生成算法

### 5.1 核心逻辑（纯规则，无 LLM）

策略生成是**模板查找 + 直接映射**，不涉及复杂计算：

```python
# app/services/strategy_service.py

class StrategyService:
    """卷面策略生成服务"""

    async def generate(
        self,
        db: AsyncSession,
        student: Student,
        target_score: int | None = None,
    ) -> dict:
        """
        生成卷面策略。

        逻辑：
        1. 确定目标分数
        2. 查找精确匹配的地区模板
        3. 如无精确匹配，找最近的分数档
        4. 组装 exam_strategy JSON
        5. 写入 student.exam_strategy
        """
        score = target_score or student.target_score

        # 1. 精确匹配
        template = await self._find_template(
            db, student.region_id, student.subject, score
        )

        # 2. 最近分数档匹配
        if not template:
            template = await self._find_nearest_template(
                db, student.region_id, student.subject, score
            )

        if not template:
            raise TemplateNotFoundError(
                f"未找到 {student.region_id}/{student.subject} 的模板"
            )

        # 3. 组装策略
        strategy = {
            "target_score": score,
            "total_score": template.total_score,
            "region_id": template.region_id,
            "subject": template.subject,
            "template_id": template.id,
            "key_message": template.key_message,
            "vs_lower": template.vs_lower,
            "vs_higher": template.vs_higher,
            "question_strategies": template.question_strategies,
            "exam_structure": template.exam_structure,
            "diagnosis_path": template.diagnosis_path,
            "generated_at": datetime.utcnow().isoformat(),
        }

        # 4. 写入学生记录
        student.exam_strategy = strategy
        if target_score:
            student.target_score = score
        await db.commit()

        return strategy

    async def _find_template(
        self, db: AsyncSession, region_id: str, subject: str, score: int
    ) -> RegionalTemplate | None:
        """精确匹配分数档"""
        result = await db.execute(
            select(RegionalTemplate).where(
                RegionalTemplate.region_id == region_id,
                RegionalTemplate.subject == subject,
                RegionalTemplate.target_score == score,
            )
        )
        return result.scalar_one_or_none()

    async def _find_nearest_template(
        self, db: AsyncSession, region_id: str, subject: str, score: int
    ) -> RegionalTemplate | None:
        """最近分数档匹配（向下取整）"""
        result = await db.execute(
            select(RegionalTemplate)
            .where(
                RegionalTemplate.region_id == region_id,
                RegionalTemplate.subject == subject,
                RegionalTemplate.target_score <= score,
            )
            .order_by(RegionalTemplate.target_score.desc())
            .limit(1)
        )
        return result.scalar_one_or_none()
```

### 5.2 目标分数变更对比

```python
    async def compare_strategies(
        self, old_strategy: dict, new_strategy: dict
    ) -> dict:
        """对比新旧策略，生成变更摘要"""
        old_map = {
            s["question_range"]: s for s in old_strategy.get("question_strategies", [])
        }
        new_map = {
            s["question_range"]: s for s in new_strategy.get("question_strategies", [])
        }

        upgraded = []  # try/skip → must
        downgraded = []  # must → try/skip

        attitude_rank = {"must": 3, "try": 2, "skip": 1}

        for qr, new_s in new_map.items():
            old_s = old_map.get(qr)
            if not old_s:
                continue
            old_rank = attitude_rank.get(old_s["attitude"], 0)
            new_rank = attitude_rank.get(new_s["attitude"], 0)
            if new_rank > old_rank:
                upgraded.append({
                    "question_range": qr,
                    "old_attitude": old_s["attitude"],
                    "new_attitude": new_s["attitude"],
                })
            elif new_rank < old_rank:
                downgraded.append({
                    "question_range": qr,
                    "old_attitude": old_s["attitude"],
                    "new_attitude": new_s["attitude"],
                })

        return {
            "upgraded_to_must": upgraded,
            "downgraded": downgraded,
            "key_message_diff": new_strategy.get("vs_lower", ""),
        }
```

### 5.3 分数档匹配规则

| 场景 | 匹配策略 |
|------|---------|
| 精确匹配 | `target_score == template.target_score` |
| 无精确匹配 | 向下取最近档（如 75 → 70 档） |
| 低于最低档 | 使用最低档模板 |
| 无任何模板 | 返回 404 错误 |

---

## 六、Pydantic Schema 设计

### 6.1 请求/响应 Schema

```python
# app/schemas/strategy.py（新建）

from pydantic import BaseModel, Field
from typing import Optional

# --- 请求 ---

class StrategyGenerateRequest(BaseModel):
    target_score: Optional[int] = Field(None, ge=30, le=150)

class TargetScoreUpdateRequest(BaseModel):
    new_target_score: int = Field(..., ge=30, le=150)

# --- 响应子结构 ---

class QuestionDetail(BaseModel):
    question_number: int | str
    max_score: int
    difficulty: str
    typical_models: list[str] = []
    typical_kps: list[str] = []

class ExamSection(BaseModel):
    section_name: str
    questions: list[QuestionDetail]

class QuestionStrategy(BaseModel):
    question_range: str
    max_score: int
    target_score: int
    attitude: str          # must / try / skip
    note: str
    display_text: str

class DiagnosisPathItem(BaseModel):
    tier: int
    model_id: str
    score_impact: str
    reason: str
    skippable: bool = False

# --- 响应 ---

class StrategyData(BaseModel):
    target_score: int
    total_score: int
    region_id: str
    subject: str
    template_id: str
    key_message: str | None = None
    vs_lower: str | None = None
    vs_higher: str | None = None
    question_strategies: list[QuestionStrategy]
    exam_structure: list[ExamSection]
    diagnosis_path: list[DiagnosisPathItem]
    generated_at: str

class StrategyResponse(BaseModel):
    has_strategy: bool
    strategy: StrategyData | None = None

class AttitudeChange(BaseModel):
    question_range: str
    old_attitude: str
    new_attitude: str
    related_models: list[str] = []

class StrategyChanges(BaseModel):
    upgraded_to_must: list[AttitudeChange]
    downgraded: list[AttitudeChange]
    key_message_diff: str

class TargetScoreUpdateResponse(BaseModel):
    old_target_score: int
    new_target_score: int
    strategy: StrategyData
    changes: StrategyChanges

class TemplateListResponse(BaseModel):
    region_id: str
    subject: str
    available_scores: list[int]
```

---

## 七、前端对接改造

### 7.1 当前状态

| 组件 | 现状 | 需改造 |
|------|------|--------|
| `RegisterStrategyPage` | 占位页面，显示"功能开发中" | ✅ 改为完整策略展示页 |
| `TopFrameWidget` | 空 Placeholder | ✅ 实现返回按钮 + 标题「卷面策略」 |
| `MainContentWidget` | 空 Placeholder | ✅ 实现策略表格 + 态度色块 + 关键话术 |
| Provider | 无 | ✅ 新建 `strategyProvider` |

### 7.2 Provider 设计

```dart
// providers/strategy_provider.dart（新建）

class StrategyState {
  final bool isLoading;
  final bool hasStrategy;
  final StrategyData? strategy;
  final String? errorMessage;
}

class StrategyNotifier extends StateNotifier<StrategyState> {
  final ApiClient _api;

  /// 获取当前策略
  Future<void> fetchStrategy() async {
    // GET /api/strategy → 更新 state
  }

  /// 生成策略
  Future<void> generateStrategy({int? targetScore}) async {
    // POST /api/strategy/generate → 更新 state
  }

  /// 修改目标分数
  Future<TargetScoreUpdateResponse> updateTargetScore(int newScore) async {
    // PUT /api/strategy/target-score → 返回变更对比
  }
}
```

### 7.3 页面交互流程

```
用户从个人中心点击「卷面策略」
    ↓
RegisterStrategyPage 加载
    ↓ fetchStrategy()
已有策略？
    ├── 是 → 展示策略表格 + 关键话术 + 修改目标分按钮
    └── 否 → 展示"尚未生成策略"提示 + 生成按钮
    ↓
用户点击「修改目标分」
    ↓ 弹出输入框
输入新目标分 → updateTargetScore(newScore)
    ↓
展示变更对比弹窗（哪些题态度升级/降级）
    ↓
用户确认 → 刷新策略展示
```

### 7.4 UI 设计要点（来自产品规格）

**核心原则：** 策略展示是核心转化页面，家长也能截图理解。

**MainContentWidget 布局：**

```
┌─────────────────────────────────┐
│  🎯 我的目标：70分 / 100分      │  ← 大数字 + 编辑按钮
│  [修改目标分]                    │
├─────────────────────────────────┤
│  💬 "选择题最多错2个，大题前两   │  ← key_message 关键话术
│     道拿满。你做得到的。"        │
├─────────────────────────────────┤
│  📋 卷面策略表                   │
│  ┌───────────┬────┬────┬─────┐ │
│  │ 题号/区域  │满分│目标│ 态度│ │
│  ├───────────┼────┼────┼─────┤ │
│  │ 选择1-6   │ 18 │ 18 │ 🔴  │ │
│  │ 选择7-8   │  6 │  3 │ 🟡  │ │
│  │ 实验题    │ 15 │ 10 │ 🟡  │ │
│  │ 大题1     │ 12 │ 12 │ 🔴  │ │
│  │ 大题2     │ 14 │ 10 │ 🟡  │ │
│  │ 大题3     │ 18 │  5 │ ⚪  │ │
│  │ 选做题    │ 15 │ 12 │ 🔴  │ │
│  └───────────┴────┴────┴─────┘ │
├─────────────────────────────────┤
│  📊 分数档对比                   │
│  vs 60分：比60分多要求...        │  ← vs_lower
│  vs 80分：比80分允许放弃...      │  ← vs_higher
└─────────────────────────────────┘
```

**态度色块映射：**
- `must` → `Color(0xFFE53935)` 红色
- `try` → `Color(0xFFFFA726)` 橙黄色
- `skip` → `Color(0xFFBDBDBD)` 灰色

---

## 八、实施阶段规划

### Phase 1：后端核心

| 步骤 | 内容 | 产出文件 |
|------|------|---------|
| 1.1 | RegionalTemplate ORM 补充 key_message/vs_lower/vs_higher + Alembic 迁移 | `app/models/regional_template.py`, `alembic/versions/` |
| 1.2 | 新增 Pydantic Schema | `app/schemas/strategy.py`（新建） |
| 1.3 | 实现 StrategyService（模板查找 + 策略生成 + 对比） | `app/services/strategy_service.py`（新建） |
| 1.4 | 实现 StrategyRouter（4 个端点） | `app/routers/strategy.py`（新建） |
| 1.5 | main.py 注册路由 | `app/main.py`（改造） |

**验收标准：** 通过 curl 调用 4 个端点，生成策略、查询策略、修改目标分并获取对比结果

### Phase 2：种子数据 + 注册流程集成

| 步骤 | 内容 | 产出文件 |
|------|------|---------|
| 2.1 | 天津物理 4 个分数档种子数据（60/70/80/90） | `seeds/regional_templates.json` 或迁移脚本 |
| 2.2 | 注册流程集成：register 成功后自动调用 strategy/generate | `app/routers/auth.py`（改造） |
| 2.3 | 教研数据需求清单补充（其他城市模板格式说明） | `docs/data-requirements/` |

**验收标准：** 新用户注册后自动生成卷面策略，`students.exam_strategy` 非空

### Phase 3：前端对接

| 步骤 | 内容 | 产出文件 |
|------|------|---------|
| 3.1 | 新建 strategyProvider | `providers/strategy_provider.dart`（新建） |
| 3.2 | TopFrameWidget 实现返回按钮 + 标题 | `widgets/top_frame_widget.dart`（改造） |
| 3.3 | MainContentWidget 实现策略表格 + 态度色块 | `widgets/main_content_widget.dart`（改造） |
| 3.4 | RegisterStrategyPage 集成 Provider + Widget | `register_strategy_page.dart`（改造） |
| 3.5 | 目标分数修改弹窗 + 变更对比展示 | `widgets/target_score_dialog.dart`（新建） |

**验收标准：** Flutter App 中查看卷面策略、修改目标分数并看到变更对比

---

## 九、数据依赖说明

### 9.1 教研数据需求（需用户/教研团队提供）

| 数据项 | 说明 | 格式 |
|--------|------|------|
| 天津物理卷面结构 | 每道题的题号、满分、难度、关联模型/知识点 | `exam_structure` JSON |
| 天津物理 60/70/80/90 分档策略 | 每个分数档的题号态度分配 | `question_strategies` JSON |
| 天津物理诊断路径 | 按分值影响排序的模型测试顺序 | `diagnosis_path` JSON |
| 关键话术 | 每个分数档的 key_message / vs_lower / vs_higher | 文本 |

> **注意：** 根据 N002 用户指令，所有教育相关数据不自行编写，统一汇总为需求清单交接给用户。天津物理模板数据需要教研老师人工设计填充。

### 9.2 与其他模块的数据关联

| 下游模块 | 依赖字段 | 用途 |
|---------|---------|------|
| AI 诊断 (PromptBuilder) | `exam_strategy` | 拼接 system prompt 中的卷面策略上下文 |
| 推荐排序 | `question_strategies[].attitude` | 🔴必须题关联的模型优先推荐 |
| 周报分析 | `exam_strategy.target_score` | 对比当前预测分 vs 目标分 |
| 成绩预测 | `exam_strategy` | 基于策略计算可达分数 |
