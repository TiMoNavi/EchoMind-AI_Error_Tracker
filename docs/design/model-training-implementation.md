# 模型训练（六步专项）功能实现设计文档

> 创建日期：2026-02-26
> 状态：设计阶段，待 foreman 审批
> 作者：claude-2 (peer)
> 依据：v1.0.md（产品核心框架 Section 五/八/十六/十九）、ai-diagnosis-implementation.md（格式参照）

---

## 一、概述

### 1.1 功能定位

模型训练是 EchoMind 的核心学习模块。当 AI 诊断判定学生的错误根源为「模型应用缺口」时，系统自动引导学生进入六步专项训练，针对性突破瓶颈层。

六步训练体系：

| Step | 名称 | 训练目标 | 交互方式 |
|------|------|---------|---------|
| 1 | 过程拆分+识别 | 拆分运动过程、确定主语、选择模型 | AI给题→学生拆过程+选主语+选模型 |
| 2 | 决策（公式选择） | 在已确定的过程+主语下穷举公式排除 | 显示可用公式列表→学生排除选择 |
| 3 | 步骤（标准解题） | 理解该模型的标准解题流程 | AI讲解标准步骤，学生确认理解 |
| 4 | 陷阱（常见错误） | 识别该模型的常见错误 | AI展示常见错误→学生判断对错 |
| 5 | 回归（分步填空） | 全流程验证，分步骤填空 | 3-5步填空，AI逐步判定+即时反馈 |
| 6 | 变式（变式题） | 换场景/数值验证迁移能力 | 给变式题→学生完整解答 |

### 1.2 掌握度与训练的关系

模型掌握度 L0-L5 直接编码瓶颈层，Level 即入口：

| Level | 状态 | 瓶颈层 | 训练入口 |
|-------|------|--------|---------|
| L0 | 未接触 | — | Step 1（完整流程） |
| L1 | 建模卡住 | 过程拆分/模型识别 | Step 1 |
| L2 | 列式卡住 | 公式选择 | Step 2 |
| L3 | 执行卡住 | 代入/计算/检查 | Step 3 |
| L4 | 做对过 | 需验证稳定性 | Step 5 |
| L5 | 稳定掌握 | 变式/延时复测 | Step 6 |

### 1.3 设计约束（来自产品规格）

- 只做 AI 提示词拼接，不做 AI 模型训练
- 每步约 1 次 LLM 调用（~0.1 元/步），单次完整训练 4-6 次调用（0.4-0.6 元）
- 预设内容（候选模型、公式、标准步骤、陷阱、填空题、变式题）由教研团队维护
- AI 负责个性化对话过渡和判定，不负责生成教学内容骨架
- 正向引导原则：语气简洁严格但不放水，永远不说"你不行"
- Step 5 超 90 秒不输入触发"不敢写"检测
- 路由层纯规则（if-else），对话层调 LLM

---

## 二、系统架构设计

### 2.1 整体数据流

```
┌─────────────┐     POST /training/start       ┌──────────────┐
│  Flutter App │ ──────────────────────────────→ │  FastAPI      │
│  (Riverpod)  │     {model_id, source}         │  Router       │
│              │                                 │  /training    │
│              │     POST /training/interact     │               │
│              │ ──────────────────────────────→ │               │
│              │     {session_id, content}       │               │
│              │                                 └───────┬───────┘
│              │                                         │
│              │     JSON response                       │
│              │ ←──────────────────────────────          │
│              │     {ai_reply, step_result}     ┌───────▼───────┐
└─────────────┘                                 │TrainingService │
                                                │               │
                                                │ 1. 路由层判定  │
                                                │ 2. 加载预设内容│
                                                │ 3. 拼接提示词  │
                                                │ 4. 调用 LLM   │
                                                │ 5. 解析判定    │
                                                │ 6. 更新掌握度  │
                                                └───────┬───────┘
                                                        │
                                         ┌──────────────┼──────────────┐
                                         ▼              ▼              ▼
                                  ┌───────────┐  ┌───────────┐  ┌──────────┐
                                  │ PostgreSQL │  │ LLM API   │  │ 预设内容  │
                                  │ sessions   │  │ (外部)     │  │ models表 │
                                  └───────────┘  └───────────┘  └──────────┘
```

### 2.2 两层架构

| 层 | 职责 | 实现方式 | 成本 |
|----|------|---------|------|
| **路由层** | 决定从哪步开始、步骤间跳转、升降级 | 纯规则（if-else），读 mastery 标签 | 0 |
| **对话层** | 在某步内与学生互动（讲解/提问/判定） | LLM prompt 拼接调用 | ~0.1元/次 |

### 2.3 核心组件

| 组件 | 职责 | 位置 |
|------|------|------|
| TrainingRouter | HTTP 端点，请求校验，JWT 鉴权 | `app/routers/training.py`（改造） |
| TrainingService | 业务逻辑：路由判定、会话管理、LLM 调用 | `app/services/training_service.py`（改造） |
| TrainingRouter（路由层） | 纯规则引擎：Level→入口Step、步骤跳转 | `app/services/training_router_engine.py`（新建） |
| TrainingPromptBuilder | 每步提示词模板拼接 | `app/services/training_prompt_builder.py`（新建） |
| TrainingSessionModel (ORM) | 训练会话持久化 | `app/models/training_session.py`（新建） |
| TrainingMessageModel (ORM) | 训练消息持久化 | `app/models/training_message.py`（新建） |
| TrainingStepResultModel (ORM) | 每步训练结果记录 | `app/models/training_step_result.py`（新建） |
| LLMClient | LLM API 封装（复用诊断模块） | `app/core/llm_client.py`（已有） |

---

## 三、API 端点设计

### 3.1 端点总览

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| POST | `/api/models/training/start` | 创建训练会话（路由层自动判定入口Step） | JWT |
| POST | `/api/models/training/interact` | 步内交互（发送回答，获取AI回复/判定） | JWT |
| POST | `/api/models/training/next-step` | 完成当前步骤，进入下一步 | JWT |
| GET | `/api/models/training/session/{session_id}` | 获取会话详情（含消息历史+步骤结果） | JWT |
| GET | `/api/models/training/session` | 获取当前活跃训练会话 | JWT |
| POST | `/api/models/training/complete` | 手动结束训练会话 | JWT |

### 3.2 端点详细定义

#### POST `/api/models/training/start`

创建新的训练会话，路由层自动判定入口 Step。

**请求体：**
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

**响应（201）：**
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

**逻辑：**
1. 校验 model_id 存在
2. 检查是否已有活跃会话（同一模型同一时间只允许一个）
3. 加载学生掌握度（`student_mastery` WHERE target_type='model' AND target_id=model_id）
4. **路由层判定入口 Step**（见 Section 五 路由规则）
5. 加载该 Step 的预设内容（候选模型/公式/步骤等）
6. 拼接 system prompt + 调用 LLM 生成开场白
7. 持久化会话 + 首条消息

#### POST `/api/models/training/interact`

步内交互：学生发送回答，获取 AI 回复和判定结果。

**请求体：**
```json
{
  "session_id": "uuid",
  "content": "我觉得应该用动量守恒定律"
}
```

**响应（200）：**
```json
{
  "message": {
    "id": "uuid",
    "role": "assistant",
    "content": "不错，你选对了模型。那这道题有几个过程？每个过程的研究对象是谁？",
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

**当步骤完成时，响应额外包含 step_result：**
```json
{
  "message": { "..." },
  "step_status": "completed",
  "step_result": {
    "step": 1,
    "passed": true,
    "ai_summary": "你成功识别了动量守恒模型，过程拆分也正确",
    "details": {
      "selected_model": "momentum_conservation",
      "correct_model": "momentum_conservation",
      "process_split_correct": true
    }
  },
  "next_step_hint": {
    "next_step": 2,
    "step_name": "决策（公式选择）",
    "auto_advance": false
  },
  "session": {
    "session_id": "uuid",
    "status": "active",
    "current_step": 1
  }
}
```

**逻辑：**
1. 校验 session 归属 + 状态为 active
2. 加载历史消息，组装 LLM messages（含 system prompt + 预设内容）
3. 持久化用户消息
4. 调用 LLM 获取回复
5. 解析 AI 输出：判定学生回答是否正确（规则匹配 or AI 判定）
6. 如果当前步骤完成：生成 step_result，提示可进入下一步
7. 持久化 AI 消息 + 更新会话状态

#### POST `/api/models/training/next-step`

完成当前步骤，进入下一步。前端在收到 `step_status: "completed"` 后调用。

**请求体：**
```json
{
  "session_id": "uuid"
}
```

**响应（200）：**
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
    "step_name": "决策（公式选择）",
    "preset_content": {
      "candidate_formulas": [
        {"id": "f1", "formula": "F=ma", "applicable": true},
        {"id": "f2", "formula": "p=mv", "applicable": false}
      ]
    }
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

**逻辑：**
1. 校验当前步骤已完成（step_result 存在且 passed=true）
2. 路由层判定下一步（可能跳步，如 L4 从 Step 5 直接到 Step 6）
3. 加载下一步预设内容
4. 拼接新步骤的 system prompt + 调用 LLM 生成开场白
5. 更新 session.current_step
6. 如果所有步骤完成 → 更新掌握度 + 设置 session.status = "completed"

**训练完成时的响应：**
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
    "next_retest_date": "2026-03-01T00:00:00Z",
    "ai_summary": "你已经完成了动量守恒模型的全流程训练，掌握度从L1提升到L4"
  }
}
```

#### GET `/api/models/training/session/{session_id}`

获取指定训练会话详情（含消息历史 + 步骤结果）。

**响应（200）：**
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

#### GET `/api/models/training/session`

获取当前用户最近的活跃训练会话。无活跃会话时返回 `null`。

#### POST `/api/models/training/complete`

手动结束训练会话（学生主动退出时调用）。

**请求体：**
```json
{
  "session_id": "uuid"
}
```

**逻辑：** 将会话状态设为 `expired`，不更新掌握度。已完成的步骤结果保留。

---

## 四、数据库 Schema 变更

### 4.1 新增表：`training_sessions`

```sql
CREATE TABLE training_sessions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id      UUID NOT NULL REFERENCES students(id),
    model_id        UUID NOT NULL,              -- 训练的模型 ID
    model_name      VARCHAR(100),               -- 模型名称（快照）
    status          VARCHAR(20) NOT NULL DEFAULT 'active',
        -- active / completed / expired
    current_step    SMALLINT NOT NULL DEFAULT 1,
    entry_step      SMALLINT NOT NULL DEFAULT 1, -- 路由层判定的入口步骤
    source          VARCHAR(30) NOT NULL DEFAULT 'self_study',
        -- error_diagnosis / self_study / quick_check / recommendation
    question_id     UUID REFERENCES questions(id), -- 来源错题（可选）
    diagnosis_result JSONB,                     -- 来源诊断结果（可选）
    system_prompt   TEXT,                       -- 当前步骤的 system prompt（快照）
    mastery_snapshot JSONB,                     -- 训练开始时的掌握度快照
    training_result JSONB,                      -- 训练完成后的结果汇总
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_train_session_student ON training_sessions(student_id);
CREATE INDEX idx_train_session_model ON training_sessions(model_id);
CREATE UNIQUE INDEX idx_train_session_active
    ON training_sessions(student_id, model_id)
    WHERE status = 'active';
    -- 同一模型同一时间只能有一个活跃训练会话
```

### 4.2 新增表：`training_messages`

```sql
CREATE TABLE training_messages (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id      UUID NOT NULL REFERENCES training_sessions(id) ON DELETE CASCADE,
    role            VARCHAR(10) NOT NULL,  -- 'user' / 'assistant' / 'system'
    content         TEXT NOT NULL,
    step            SMALLINT NOT NULL,     -- 该消息属于哪个训练步骤
    token_count     INTEGER,               -- token 数（成本统计）
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_train_msg_session ON training_messages(session_id, created_at);
```

### 4.3 新增表：`training_step_results`

```sql
CREATE TABLE training_step_results (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id      UUID NOT NULL REFERENCES training_sessions(id) ON DELETE CASCADE,
    step            SMALLINT NOT NULL,     -- 步骤编号 1-6
    passed          BOOLEAN NOT NULL,      -- 是否通过
    ai_summary      TEXT,                  -- AI 对该步骤的总结
    details         JSONB,                 -- 步骤特定的详细结果
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(session_id, step)               -- 每个会话每步只有一条结果
);

CREATE INDEX idx_train_step_session ON training_step_results(session_id);
```

### 4.4 现有表变更

**`student_mastery` 表** — 无需改动，已有字段支持模型掌握度：
- `target_type`: 'model'
- `target_id`: 模型 UUID
- `current_level`: 0-5
- `peak_level`: 0-5
- `mastery_value`: 0-100
- `last_active`: timestamp
- `is_unstable`: bool
- `next_retest_date`: timestamp

训练完成后由 TrainingService 更新上述字段。

### 4.5 ORM 模型

```python
# app/models/training_session.py
class TrainingSessionModel(Base):
    __tablename__ = "training_sessions"
    id: Mapped[uuid.UUID]           # PK
    student_id: Mapped[uuid.UUID]   # FK → students
    model_id: Mapped[uuid.UUID]     # 训练的模型 ID
    model_name: Mapped[str | None]  # 模型名称快照
    status: Mapped[str]             # active/completed/expired
    current_step: Mapped[int]       # 当前步骤 1-6
    entry_step: Mapped[int]         # 入口步骤
    source: Mapped[str]             # 来源路径
    question_id: Mapped[uuid.UUID | None]  # FK → questions（可选）
    diagnosis_result: Mapped[dict | None]  # JSONB
    system_prompt: Mapped[str | None]
    mastery_snapshot: Mapped[dict | None]  # JSONB
    training_result: Mapped[dict | None]   # JSONB
    created_at: Mapped[datetime]
    updated_at: Mapped[datetime]
```

```python
# app/models/training_message.py
class TrainingMessageModel(Base):
    __tablename__ = "training_messages"
    id: Mapped[uuid.UUID]           # PK
    session_id: Mapped[uuid.UUID]   # FK → training_sessions
    role: Mapped[str]               # user/assistant/system
    content: Mapped[str]
    step: Mapped[int]               # 所属步骤
    token_count: Mapped[int | None]
    created_at: Mapped[datetime]
```

```python
# app/models/training_step_result.py
class TrainingStepResultModel(Base):
    __tablename__ = "training_step_results"
    id: Mapped[uuid.UUID]           # PK
    session_id: Mapped[uuid.UUID]   # FK → training_sessions
    step: Mapped[int]               # 步骤编号 1-6
    passed: Mapped[bool]
    ai_summary: Mapped[str | None]
    details: Mapped[dict | None]    # JSONB
    created_at: Mapped[datetime]
```

### 4.6 Alembic 迁移

新增一个迁移文件创建上述三张表，命名：`add_training_session_tables`

---

## 五、路由规则实现

### 5.1 路由引擎设计

路由层为纯规则引擎，不调用 LLM，零成本。核心职责：
1. 判定训练入口 Step
2. 步骤间跳转逻辑
3. 训练完成后的掌握度升降级

```python
# app/services/training_router_engine.py

class TrainingRouterEngine:
    """模型训练路由引擎（纯规则，不调 LLM）"""

    def determine_entry_step(
        self,
        source: str,
        current_level: int,
        peak_level: int,
        last_active: datetime | None,
        diagnosis_result: dict | None,
    ) -> int:
        """判定训练入口步骤，返回 Step 编号 1-6"""
        ...

    def determine_next_step(
        self,
        current_step: int,
        step_passed: bool,
        entry_step: int,
        current_level: int,
    ) -> int | None:
        """判定下一步骤，返回 None 表示训练完成"""
        ...

    def calculate_mastery_update(
        self,
        step_results: list[dict],
        current_mastery: float,
        current_level: int,
    ) -> dict:
        """根据训练结果计算掌握度更新"""
        ...
```

### 5.2 入口判定规则（按优先级从上到下匹配）

```
⚠️ 命中第一条即停止，核心原则：Level 直接编码瓶颈层

优先级1：从没学过
├── peak_level == 0 → 入口=Step 1（完整流程，含过程拆分教学）

优先级2：做错题分流进来（已有诊断结果）
├── source == "error_diagnosis"
│   ├── 诊断=识别错 → 入口=Step 1（建模层训练）
│   ├── 诊断=决策错 → 入口=Step 2（列式层训练）
│   └── 诊断=步骤错/代入错/主语错/计算错 → 入口=Step 3（执行层训练）

优先级3：久未练习（非做错题场景）
├── peak_level > 0 && last_active > 14天 → 快检
│   ├── 快检通过 → Step 5（回归验证）
│   └── 快检不通过 → current_level 降到 L1 → Step 1

优先级4：正常路由（Level 即入口）
├── current_level == 1 → Step 1
├── current_level == 2 → Step 2
├── current_level == 3 → Step 3
├── current_level == 4 → Step 5
└── current_level == 5 → Step 6
```

### 5.3 步骤跳转规则

```
当前步骤完成后，下一步判定：

Step 1 通过：
├── Step 2 失败（公式还不行）→ 进 Step 2
├── Step 2 也通过 → 继续 Step 3
└── 后续全通过 → 直接跳到 Step 5（可跨级到 L4）

Step 2 通过：
├── 进 Step 3

Step 3 通过：
├── 进 Step 4

Step 4 通过：
├── 进 Step 5

Step 5 通过（回归验证对）：
├── 进 Step 6（变式）
├── 训练完成后进入延时复测队列

Step 5 失败（回归验证错）：
├── AI 诊断定位出错的层
│   ├── 识别层出错 → 退回 Step 1
│   ├── 列式层出错 → 退回 Step 2
│   └── 执行层出错 → 退回 Step 3

Step 6 通过（变式对）：
├── 训练完成 → 升级到 L5（需满足延时复测条件）

Step 6 失败（变式错）：
├── 降到 L4 → 下次进 Step 5

任何步骤失败（非 Step 5/6）：
├── 在当前步骤内重试（AI 换个角度引导）
├── 重试 ≥ 2 次仍失败 → 记录失败，允许跳过进入下一步
```

### 5.4 掌握度更新规则

```python
# 训练完成后的掌握度更新逻辑（伪代码）

def update_mastery_after_training(step_results, current_mastery, current_level):
    """
    mastery_value 更新公式（模型专用参数）：
    - base_r = 10, base_p = 15
    - step_weight: Step 1-2 = 1.2, Step 3-6 = 1.0（对应解题9步的权重）
    - confidence = 1.0（训练场景固定）
    """
    for result in step_results:
        step_weight = 1.2 if result.step <= 2 else 1.0
        if result.passed:
            reward = 10 * (1 - current_mastery/100) * 1.0 * step_weight
            current_mastery += reward
        else:
            penalty = 15 * (current_mastery/100) * 1.0 * step_weight
            current_mastery -= penalty

    # 边界保护
    current_mastery = max(5, min(100, current_mastery))

    # mastery_value → Level 映射
    new_level = mastery_to_level(current_mastery)
    return {"mastery_value": current_mastery, "new_level": new_level}

def mastery_to_level(value):
    if value == 0: return 0
    if value < 20: return 1
    if value < 40: return 2
    if value < 60: return 3
    if value < 80: return 4
    return 5
```

---

## 六、提示词工程

### 6.1 总体设计

每个 Step 有独立的 system prompt 模板。模板在会话创建/步骤切换时一次性拼接，步内对话不再修改。

AI 输出约定标记：
- `[STEP_PASS]` — AI 判定当前步骤通过
- `[STEP_FAIL]` — AI 判定当前步骤失败
- `[NEED_RETRY]` — 需要学生重试当前问题

```python
# app/services/training_prompt_builder.py

class TrainingPromptBuilder:
    """模型训练提示词拼接引擎"""

    def build_step_prompt(
        self,
        step: int,
        model_name: str,
        preset_content: dict,
        student_context: dict,
    ) -> str:
        """根据步骤编号选择对应模板并拼接"""
        templates = {
            1: self._build_step1_prompt,
            2: self._build_step2_prompt,
            3: self._build_step3_prompt,
            4: self._build_step4_prompt,
            5: self._build_step5_prompt,
            6: self._build_step6_prompt,
        }
        return templates[step](model_name, preset_content, student_context)
```

### 6.2 Step 1 提示词：过程拆分+识别

```
[角色定义]
你是 EchoMind 模型训练助手，正在帮助学生训练「{model_name}」的识别能力。

[行为准则]
- 语气简洁严格，不放水
- 每次回复不超过 3 句话
- 正向引导：不说"你不行"，只说"再想想"

[学生画像]
- 模型掌握度：current_level={current_level}, peak_level={peak_level}
- 来源路径：{source}
- 诊断结果（如有）：{error_subtype}
- 不稳定标记：{is_unstable}

[训练任务 — Step 1 过程拆分+识别]
引导学生完成以下子任务：
1. 拆分运动过程（这道题有几个阶段？）
2. 确定每个过程的研究对象（主语是谁？）
3. 从候选模型中选择正确的模型

[预设内容]
题目信息：{question_summary}
候选模型列表：{candidate_models}
正确答案：模型={correct_model}，过程拆分={correct_process_split}

[特殊规则]
- 如果学生是"主语错"进来的，重点引导"对谁列式？对哪个过程？"
- 如果 is_unstable==true，增加追问深度（多问 1 轮确认）
- 穷举所有选项 → 逐个排除 → 锁定正确路径

[输出格式]
- 正常对话：自然语言引导
- 判定通过时：在回复末尾附加 [STEP_PASS]
- 判定失败时：在回复末尾附加 [STEP_FAIL]
- 需要重试时：在回复末尾附加 [NEED_RETRY]
```

### 6.3 Step 2 提示词：决策（公式选择）

```
[角色定义]
你是 EchoMind 模型训练助手，正在帮助学生训练「{model_name}」的公式选择能力。

[行为准则]
- 语气简洁严格，不放水
- 每次回复不超过 3 句话

[训练任务 — Step 2 决策]
引导学生从可用公式列表中，逐个排除确定正确公式。
核心逻辑：穷举所有选项 → 逐个排除 → 锁定正确路径

[预设内容]
可用公式列表：{candidate_formulas}
正确公式：{correct_formula}
排除理由（每个错误公式为什么不适用）：{exclusion_reasons}

[输出格式]
- 判定通过时：回复末尾附加 [STEP_PASS]
- 判定失败时：回复末尾附加 [STEP_FAIL]
- 需要重试时：回复末尾附加 [NEED_RETRY]
```

### 6.4 Step 3 提示词：步骤（标准解题）

```
[角色定义]
你是 EchoMind 模型训练助手，正在讲解「{model_name}」的标准解题步骤。

[训练任务 — Step 3 步骤]
按预设步骤讲解该模型的标准解题流程，每步让学生确认"明白了"。

[预设内容]
标准解题步骤：{standard_steps}

[输出格式]
- 每讲完一步，等学生确认后再讲下一步
- 全部讲完且学生确认理解：回复末尾附加 [STEP_PASS]
- 学生明确表示不理解：回复末尾附加 [NEED_RETRY]
```

### 6.5 Step 4 提示词：陷阱（常见错误）

```
[角色定义]
你是 EchoMind 模型训练助手，正在帮助学生识别「{model_name}」的常见陷阱。

[训练任务 — Step 4 陷阱]
展示该模型的 2-3 个常见错误，让学生判断"这里哪里错了"。

[预设内容]
常见陷阱列表：{common_traps}
每个陷阱的错误点和正确做法：{trap_explanations}

[输出格式]
- 学生正确识别所有陷阱：回复末尾附加 [STEP_PASS]
- 学生未能识别关键陷阱：回复末尾附加 [STEP_FAIL]
- 需要重试某个陷阱：回复末尾附加 [NEED_RETRY]
```

### 6.6 Step 5 提示词：回归（分步填空）

```
[角色定义]
你是 EchoMind 模型训练助手，正在验证学生对「{model_name}」的全流程掌握。

[训练任务 — Step 5 回归]
将解题过程拆为 3-5 步，每步让学生填写关键量/公式/结果。
实时判定每步对错，错误步骤立即反馈。

[预设内容]
分步填空题：{fill_in_steps}
每步的正确答案：{step_answers}
题目来源：{question_source}（首次学=预设母题，非首次=学生错题）

[特殊规则]
- 超 90 秒不输入 → 提示"是不是不太确定？没关系，先写你觉得对的"
- 比"重新做整题"更聚焦，比"看答案"更有参与感

[输出格式]
- 逐步判定，每步回复是否正确
- 全部步骤正确：回复末尾附加 [STEP_PASS]
- 关键步骤错误：回复末尾附加 [STEP_FAIL]，并指出错在哪一步
```

### 6.7 Step 6 提示词：变式（变式题）

```
[角色定义]
你是 EchoMind 模型训练助手，正在用变式题验证学生对「{model_name}」的迁移能力。

[训练任务 — Step 6 变式]
给学生一道变式题（同一模型换场景/数值），学生完整解答，AI 判定。

[预设内容]
变式题：{variant_question}
标准答案：{variant_answer}
与原题的差异点：{variant_diff}

[特殊规则]
- 变式题防止学生记住原题答案，测的是真理解
- 判定标准：关键步骤正确即可，计算小误差可容忍

[输出格式]
- 学生解答正确：回复末尾附加 [STEP_PASS]
- 学生解答错误：回复末尾附加 [STEP_FAIL]，指出错误层（识别/列式/执行）
```

### 6.8 预设内容数据来源

| 模板变量 | 数据来源 | 说明 |
|---------|---------|------|
| `candidate_models` | `models` 表 + 教研预设 | 3-4 个候选模型 |
| `candidate_formulas` | 教研预设（按模型） | 该步骤可用公式列表 |
| `standard_steps` | 教研预设（按模型） | 标准解题流程 |
| `common_traps` | 教研预设（按模型） | 2-3 个常见错误 |
| `fill_in_steps` | 教研预设 or 学生错题 | 3-5 步填空 |
| `variant_question` | 教研预设 or AI 生成 | 变式题 |
| `current_level` | `student_mastery` | 当前掌握度 |
| `is_unstable` | `student_mastery` | 不稳定标记 |
| `error_subtype` | 诊断结果 | 错误子类型 |

---

## 七、前端对接改造

### 7.1 当前状态

| 组件 | 现状 | 需改造 |
|------|------|--------|
| `ModelTrainingPage` | data 分支始终走 demo | ✅ 接入真实数据渲染 |
| `ActionOverlayWidget` | 输入栏是空壳 Container | ✅ 改为 TextField + 发送逻辑 |
| `TrainingDialogueWidget` | 硬编码 mock 气泡 | ✅ 改为 ListView.builder 动态渲染 |
| `StepStageNavWidget` | 静态步骤导航 | ✅ 根据 current_step 高亮 + 可点击 |
| `modelTrainingProvider` | FutureProvider 只调 GET | ✅ 改为 StateNotifier 管理会话状态 |
| `Step1IdentificationTrainingWidget` | 静态展示 | ✅ 接入 Step 1 交互逻辑 |

### 7.2 Provider 改造

现有 `modelTrainingProvider` 是 `FutureProvider<TrainingSession?>`，只支持一次性 GET。

改造为 `StateNotifierProvider`：

```dart
// providers/model_training_provider.dart（改造后）

class TrainingState {
  final String? sessionId;
  final String modelId;
  final String modelName;
  final String status;        // idle / active / completed
  final int currentStep;      // 1-6
  final int entryStep;
  final List<TrainingMsg> messages;
  final Map<int, StepResult> stepResults;  // step → result
  final TrainingResult? trainingResult;
  final bool isSending;       // 发送中状态
  final String? stepStatus;   // in_progress / completed
}

class TrainingNotifier extends StateNotifier<TrainingState> {
  final ApiClient _api;

  /// 创建训练会话
  Future<void> startSession(String modelId, {
    String source = 'self_study',
    String? questionId,
    Map<String, dynamic>? diagnosisResult,
  }) async {
    // POST /models/training/start → 更新 state
  }

  /// 步内交互：发送回答
  Future<void> sendMessage(String content) async {
    // 1. 添加用户消息到 state.messages
    // 2. state.isSending = true
    // 3. POST /models/training/interact
    // 4. 添加 AI 回复到 state.messages
    // 5. 如果 step_status == completed，更新 stepResults
  }

  /// 进入下一步
  Future<void> nextStep() async {
    // POST /models/training/next-step → 更新 currentStep + messages
  }

  /// 手动结束
  Future<void> completeSession() async {
    // POST /models/training/complete
  }
}
```

### 7.3 用户交互流程

```
学生从错题诊断结论 / 模型详情页点击「开始训练」
    ↓
ModelTrainingPage 加载
    ↓ startSession(modelId, source, ...)
路由层判定入口 Step → 显示 AI 开场白
    ↓
StepStageNavWidget 高亮当前步骤
    ↓
学生输入回答 → 点击发送
    ↓ sendMessage(content)
显示 loading → AI 回复 + 判定
    ↓ 重复步内交互...
AI 输出 [STEP_PASS] → 步骤完成
    ↓
显示「进入下一步」按钮
    ↓ nextStep()
切换到下一步 → 新的 AI 开场白
    ↓ 重复...
所有步骤完成 → 显示训练结果卡
    ↓
掌握度更新动画 + 「返回」按钮
```

---

## 八、实施阶段规划

### Phase 1：后端核心（优先级最高）

| 步骤 | 内容 | 产出文件 |
|------|------|---------|
| 1.1 | 新增 ORM 模型（3 张表） | `app/models/training_session.py`, `training_message.py`, `training_step_result.py` |
| 1.2 | Alembic 迁移 | `alembic/versions/add_training_session_tables.py` |
| 1.3 | 新增/改造 Pydantic Schema | `app/schemas/training.py`（改造） |
| 1.4 | 实现路由引擎（纯规则） | `app/services/training_router_engine.py`（新建） |
| 1.5 | 实现 TrainingPromptBuilder | `app/services/training_prompt_builder.py`（新建） |
| 1.6 | 实现 TrainingService 核心逻辑 | `app/services/training_service.py`（改造） |
| 1.7 | 改造 TrainingRouter（6 个端点） | `app/routers/training.py`（改造） |

**验收标准：** 通过 curl/httpie 手动调用 API，完成一次完整 6 步训练流程

### Phase 2：前端对接

| 步骤 | 内容 | 产出文件 |
|------|------|---------|
| 2.1 | 改造 TrainingState + TrainingNotifier | `providers/model_training_provider.dart`（改造） |
| 2.2 | ActionOverlayWidget 改为真实 TextField + 发送 | `widgets/action_overlay_widget.dart`（改造） |
| 2.3 | TrainingDialogueWidget 改为动态 ListView.builder | `widgets/training_dialogue_widget.dart`（改造） |
| 2.4 | StepStageNavWidget 接入 current_step 高亮 | `widgets/step_stage_nav_widget.dart`（改造） |
| 2.5 | ModelTrainingPage data 分支接入真实渲染 | `model_training_page.dart`（改造） |
| 2.6 | 训练结果卡 + 掌握度更新动画 | `widgets/training_result_card.dart`（新建） |

**验收标准：** Flutter App 中完成一次完整 6 步训练，步骤导航正确切换，结果卡正确展示

### Phase 3：掌握度集成与质量保障

| 步骤 | 内容 |
|------|------|
| 3.1 | 训练完成后自动更新 `student_mastery`（mastery_value + current_level） |
| 3.2 | 延时复测队列：Step 5 通过后安排 3/7/30 天复测 |
| 3.3 | 后端单元测试（mock LLM 响应，覆盖路由引擎全路径） |
| 3.4 | 提示词 A/B 测试（用真实错题验证训练效果） |
| 3.5 | 异常处理：LLM 超时/限流/格式错误的降级策略 |
| 3.6 | 教研预设内容管理接口（CRUD 候选模型/公式/陷阱等） |

**验收标准：** 路由引擎单元测试覆盖率 ≥ 90%，掌握度升降级逻辑正确，异常场景有优雅降级
