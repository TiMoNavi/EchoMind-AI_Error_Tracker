# 知识点学习功能实现设计文档

> 创建日期：2026-02-26
> 状态：设计阶段
> 作者：claude-1 (foreman)
> 依据：v1.0.md（产品核心框架 Section三/六/七）、ai-diagnosis-implementation.md（格式参照）

---

## 一、概述

### 1.1 功能定位

知识点学习是 EchoMind 的三大核心学习路径之一。当 AI 诊断判定学生的错误根源为「知识点缺口」时，系统引导学生进入知识点学习流程。学生也可主动从知识点 Tab 进入学习。

核心理念：**预设内容是骨架，AI 是个性化调度引擎**。

| 来源路径 | 触发条件 | 进入方式 |
|---------|---------|---------|
| AI 诊断分流 | 错题诊断结果 = 知识点缺口 | 自动跳转，从 Step 4 开始（有基础） |
| 主动学习 | 学生在知识点 Tab 点击某知识点 | 完整 5 步流程 |
| 模型训练暴露 | 六步专项中发现基础概念不会 | 插入快检确认 |
| 周复盘防腐 | 每周对已掌握知识点抽检 | 1-2 道快检 |

### 1.2 五步 AI 引导工作流

```
Step 1: AI 判断学生当前状态
    ├── 完全陌生 → 进入 Step 2（完整流程）
    └── 有基础（从诊断分流来）→ 跳到 Step 4（直接检测）

Step 2: 按序呈现预设内容
    定义 → 公式(如有) → 适用条件(如有) → 注意事项 → 图示(如有)
    AI 在每个模块间用对话过渡，确认学生理解

Step 3: 关键点确认
    AI 针对核心概念提问，确保理解（非做题，而是解释性提问）
    例："用你自己的话说说，电荷量和电荷有什么区别？"

Step 4: 概念检测
    呈现预设的 2-3 道检测题
    ├── 全对 → Step 5
    └── 有错 → AI 针对性讲解薄弱环节 → 再次检测

Step 5: 完成 + 关联推荐 + 自动生成闪卡
    更新知识点掌握度
    自动生成对应闪卡（概念卡/条件卡/辨析卡）
    推荐关联模型："这个知识点在【库仑力平衡模型】中会用到，要去看看吗？"
```

### 1.3 知识点掌握度与学习流程的关系

| Level | 状态 | 含义 | 对应训练 |
|-------|------|------|---------|
| L0 | 未接触 | 从没学过 | — |
| L1 | 记不住 | 公式/概念回忆不出来 | 闪卡 + 重新呈现(Step 2) |
| L2 | 理解不深 | 能回忆但说不清为什么 | AI 讲解 + 条件检测(Step 3-4) |
| L3 | 使用出错 | 理解了但在题目中用错 | 辨析训练 + 概念检测(Step 4) |
| L4 | 能正确使用 | 检测正确 + 能解释 ≥ 1次 | 延时复测 |
| L5 | 稳定掌握 | 延时复测通过(≥24h) ≥ 2次 | 周复盘防腐 |

### 1.4 设计约束

- 只做 AI 提示词拼接，不做 AI 模型训练
- 预设内容由教研团队制作，AI 不生成图片/视频
- 图示为预设静态图，题库中可含图片
- 正向引导原则：永远不说"你不行"，只说"你还差一步"
- 每次 AI 回复不超过 3 句话，保持简洁

---

## 二、系统架构设计

### 2.1 整体数据流

```
┌─────────────┐     POST /knowledge/learning/start    ┌──────────────┐
│  Flutter App │ ────────────────────────────────────→ │  FastAPI      │
│  (Riverpod)  │     {knowledge_point_id}             │  Router       │
│              │                                       │  /knowledge   │
│              │     POST /knowledge/learning/chat     │  /learning    │
│              │ ────────────────────────────────────→ │               │
│              │     {session_id, content}             └───────┬───────┘
│              │                                               │
│              │     JSON response                             │
│              │ ←────────────────────────────────             │
│              │     {role, content, step, metadata}    ┌──────▼────────┐
└─────────────┘                                        │LearningService│
                                                       │               │
                                                       │ 1. 加载预设内容│
                                                       │ 2. 判断学生状态│
                                                       │ 3. 拼接提示词  │
                                                       │ 4. 调用 LLM   │
                                                       │ 5. 更新掌握度  │
                                                       └──────┬────────┘
                                                              │
                                        ┌─────────────────────┼──────────────────┐
                                        ▼                     ▼                  ▼
                                 ┌───────────┐        ┌───────────┐      ┌────────────┐
                                 │ PostgreSQL │        │ LLM API   │      │ PresetContent│
                                 │ sessions   │        │ (Gemini等) │      │ (教研预设)   │
                                 └───────────┘        └───────────┘      └────────────┘
```

### 2.2 核心组件

| 组件 | 职责 | 位置 |
|------|------|------|
| LearningRouter | HTTP 端点，请求校验，JWT 鉴权 | `app/routers/learning.py`（改造） |
| LearningService | 业务逻辑：会话管理、步骤调度、LLM 调用 | `app/services/learning_service.py`（改造） |
| LearningPromptBuilder | 知识点学习场景提示词拼接 | `app/services/learning_prompt_builder.py`（新建） |
| LearningSession (ORM) | 学习会话持久化模型 | `app/models/learning_session.py`（新建） |
| LearningMessage (ORM) | 学习对话消息持久化 | `app/models/learning_message.py`（新建） |
| LLMClient | LLM API 封装（复用 AI 诊断已有） | `app/core/llm_client.py`（已有） |

### 2.3 与 AI 诊断模块的复用关系

| 组件 | 复用方式 |
|------|---------|
| LLMClient + LLMFactory | 直接复用，同一个 Gemini/DashScope 客户端 |
| PromptBuilder | 新建 LearningPromptBuilder，不复用诊断的 |
| ORM 模型 | 新建独立表，结构类似但字段不同 |
| Router 模式 | 参照诊断的 start/chat/complete 模式 |

---

## 三、API 端点设计

### 3.1 端点总览

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| POST | `/api/knowledge/learning/start` | 创建学习会话（绑定 knowledge_point_id） | JWT |
| POST | `/api/knowledge/learning/chat` | 发送消息并获取 AI 回复 | JWT |
| GET | `/api/knowledge/learning/session/{session_id}` | 获取会话详情（含历史消息） | JWT |
| GET | `/api/knowledge/learning/session` | 获取当前活跃会话（兼容现有前端） | JWT |
| POST | `/api/knowledge/learning/complete` | 完成学习会话，触发掌握度更新 | JWT |
| GET | `/api/knowledge/learning/content/{knowledge_point_id}` | 获取知识点预设内容 | JWT |

### 3.2 端点详细定义

#### POST `/api/knowledge/learning/start`

创建新的学习会话，绑定到一个知识点。

**请求体：**
```json
{
  "knowledge_point_id": "uuid-of-knowledge-point",
  "source": "self_study | diagnosis_redirect | model_training | weekly_review"
}
```

**响应（201）：**
```json
{
  "session_id": "uuid",
  "status": "active",
  "knowledge_point_id": "uuid",
  "knowledge_point_name": "电荷量",
  "current_step": 1,
  "max_steps": 5,
  "mastery_level": "L1",
  "mastery_value": 15,
  "messages": [
    {
      "id": "uuid",
      "role": "assistant",
      "content": "我们来学习「电荷量」这个概念。先看看你对它了解多少...",
      "step": 1,
      "created_at": "2026-02-26T06:00:00Z"
    }
  ]
}
```

**逻辑：**
1. 校验 knowledge_point_id 存在
2. 检查该知识点是否已有活跃会话（有则返回已有会话）
3. 加载知识点预设内容 + 学生当前掌握度
4. 根据 source 和掌握度决定起始 Step
5. 拼接 system prompt，调用 LLM 生成开场白
6. 持久化会话 + 首条消息

#### POST `/api/knowledge/learning/chat`

学生发送消息，获取 AI 回复。AI 根据当前 Step 决定回复策略。

**请求体：**
```json
{
  "session_id": "uuid",
  "content": "电荷量就是电荷的多少吧"
}
```

**响应（200）：**
```json
{
  "message": {
    "id": "uuid",
    "role": "assistant",
    "content": "对的！电荷量就是衡量电荷多少的物理量。那你知道它的单位是什么吗？",
    "step": 2,
    "created_at": "2026-02-26T06:01:00Z"
  },
  "session": {
    "current_step": 2,
    "status": "active",
    "round": 3
  }
}
```

**逻辑：**
1. 校验 session_id 属于当前用户且状态为 active
2. 保存学生消息
3. 组装上下文：system prompt + 历史消息 + 当前 Step 指令
4. 调用 LLM 获取回复
5. 解析 AI 回复，判断是否需要推进 Step
6. 保存 AI 消息，更新会话状态

#### GET `/api/knowledge/learning/session/{session_id}`

获取指定会话详情。

**响应（200）：**
```json
{
  "session_id": "uuid",
  "status": "active | completed",
  "knowledge_point_id": "uuid",
  "knowledge_point_name": "电荷量",
  "current_step": 3,
  "max_steps": 5,
  "source": "self_study",
  "mastery_before": 15,
  "mastery_after": null,
  "messages": [...],
  "created_at": "...",
  "updated_at": "..."
}
```

#### GET `/api/knowledge/learning/session`

获取当前活跃学习会话（兼容现有前端 Provider）。无活跃会话时返回空结构。

#### POST `/api/knowledge/learning/complete`

完成学习会话，触发掌握度更新和闪卡生成。

**请求体：**
```json
{
  "session_id": "uuid"
}
```

**响应（200）：**
```json
{
  "session_id": "uuid",
  "status": "completed",
  "mastery_before": 15,
  "mastery_after": 42,
  "level_before": "L1",
  "level_after": "L3",
  "flashcards_generated": 2,
  "recommended_models": [
    {"model_id": "uuid", "name": "库仑力平衡模型"}
  ]
}
```

**逻辑：**
1. 校验会话状态为 active
2. 根据学习过程中的表现计算新掌握度
3. 更新 StudentMastery 表
4. 自动生成闪卡（概念卡/条件卡/辨析卡）
5. 查询关联模型，生成推荐
6. 标记会话为 completed

#### GET `/api/knowledge/learning/content/{knowledge_point_id}`

获取知识点的预设教学内容（教研团队制作）。

**响应（200）：**
```json
{
  "knowledge_point_id": "uuid",
  "name": "电荷量",
  "definition": "电荷的多少叫作电荷量，用Q或q表示",
  "formula": null,
  "conditions": null,
  "notes": "标量，正值记+Q，负值记-Q",
  "image_url": null,
  "test_questions": [
    {
      "id": "uuid",
      "content": "以下关于电荷量的说法正确的是...",
      "options": ["A. ...", "B. ...", "C. ...", "D. ..."],
      "answer": "B",
      "explanation": "..."
    }
  ],
  "explain_questions": [
    {
      "id": "uuid",
      "question": "用你自己的话说说，电荷量和电荷有什么区别？",
      "key_points": ["电荷量是物理量", "电荷是带电粒子"]
    }
  ]
}
```

---

## 四、数据库设计

### 4.1 新增表

#### learning_sessions（学习会话表）

```sql
CREATE TABLE learning_sessions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id      UUID NOT NULL REFERENCES students(id),
    knowledge_point_id UUID NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'active',
    source          VARCHAR(30) NOT NULL DEFAULT 'self_study',
    current_step    INTEGER NOT NULL DEFAULT 1,
    max_steps       INTEGER NOT NULL DEFAULT 5,
    mastery_before  FLOAT,
    mastery_after   FLOAT,
    level_before    VARCHAR(5),
    level_after     VARCHAR(5),
    system_prompt   TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_ls_student ON learning_sessions(student_id);
CREATE INDEX idx_ls_status ON learning_sessions(student_id, status);
```

#### learning_messages（学习对话消息表）

```sql
CREATE TABLE learning_messages (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id      UUID NOT NULL REFERENCES learning_sessions(id) ON DELETE CASCADE,
    role            VARCHAR(10) NOT NULL,
    content         TEXT NOT NULL,
    step            INTEGER NOT NULL,
    token_count     INTEGER DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_lm_session ON learning_messages(session_id, created_at);
```

### 4.2 已有表依赖

| 表 | 用途 |
|---|------|
| `students` | 学生信息，关联 student_id |
| `student_mastery` | 知识点掌握度，学习完成后更新 |
| `knowledge_points` | 知识点基础信息 |
| `flashcards` | 学习完成后自动生成闪卡 |

---

## 五、提示词模板设计

### 5.1 System Prompt（知识点学习场景）

```
你是 EchoMind 的知识点学习助手，正在帮助一名高中物理学生学习「{knowledge_point_name}」。

## 学生信息
- 当前掌握等级：{mastery_level}（{mastery_description}）
- 来源路径：{source}
- 历史表现：该知识点关联模型表现 {related_model_performance}

## 预设教学内容
{preset_content_json}

## 当前步骤：Step {current_step}
{step_instruction}

## 规则
1. 语气简洁友好，每次回复不超过 3 句话
2. 正向引导：永远不说"你不行"，只说"你还差一步"
3. 根据学生状态选择呈现哪些内容模块
4. 如果学生已有基础，可跳过已掌握部分
5. 在每个模块间用对话过渡，确认学生理解后再继续

## 输出格式
回复纯文本即可。当需要推进到下一步时，在回复末尾加标记：
[STEP_ADVANCE:{next_step}]
当判断学生已完成当前步骤的学习目标时，在回复末尾加标记：
[STEP_COMPLETE:{current_step}]
```

### 5.2 各 Step 指令模板

#### Step 1: 状态判断
```
判断学生对「{knowledge_point_name}」的当前状态。
- 如果学生完全陌生（L0/L1），回复"我们从头开始"，标记 [STEP_ADVANCE:2]
- 如果学生有基础（L2+或从诊断分流来），回复"看起来你有一些基础，我们直接测试一下"，标记 [STEP_ADVANCE:4]
- 如果不确定，问一个简单问题来判断
```

#### Step 2: 呈现预设内容
```
按以下顺序呈现预设内容，每次只呈现一个模块：
1. 定义：{definition}
2. 公式：{formula}（如有）
3. 适用条件：{conditions}（如有）
4. 注意事项：{notes}
5. 图示说明：{image_description}（如有）

每呈现一个模块后，用一句话确认学生理解，再继续下一个。
全部呈现完毕后标记 [STEP_ADVANCE:3]
```

#### Step 3: 关键点确认
```
针对核心概念提出解释性问题（非做题）：
{explain_questions}

判断学生回答是否包含关键要点：{key_points}
- 回答正确 → 鼓励 + 标记 [STEP_ADVANCE:4]
- 回答不完整 → 补充讲解 + 再次提问
- 回答错误 → 温和纠正 + 回到相关预设内容
```

#### Step 4: 概念检测
```
呈现预设检测题（一次一道）：
{test_questions}

学生回答后判断对错：
- 全对 → 鼓励 + 标记 [STEP_ADVANCE:5]
- 有错 → 针对性讲解错误原因 → 再出一道类似题
```

#### Step 5: 完成总结
```
学习完成！请输出总结：
1. 一句话概括学生学到了什么
2. 鼓励语（正向引导）
3. 推荐关联模型（如有）：{related_models}

标记 [STEP_COMPLETE:5]
```

---

## 六、前端对接方案

### 6.1 Provider 改造

现有 `knowledge_learning_provider.dart` 仅有一个 `FutureProvider` 调用 GET `/knowledge/learning/session`。需改造为支持完整会话流程的 `StateNotifierProvider`。

**新 Provider 结构：**

```dart
// 学习会话状态
class LearningSessionState {
  final LearningSession? session;
  final bool isLoading;
  final String? error;
  final int currentStep;
  final List<LearningMessage> messages;
}

// StateNotifier 管理会话生命周期
class LearningSessionNotifier extends StateNotifier<LearningSessionState> {
  Future<void> startSession(String knowledgePointId, String source);
  Future<void> sendMessage(String content);
  Future<void> completeSession();
  Future<void> loadActiveSession();
}
```

### 6.2 页面改造

现有 `KnowledgeLearningPage` 所有分支都走 `_buildDemoContent()`。改造为：

| 状态 | 展示 |
|------|------|
| 无活跃会话 | 显示"选择知识点开始学习"入口 |
| 加载中 | CircularProgressIndicator |
| 活跃会话 | TopFrame + StepNav + 对话列表 + 输入框 |
| 已完成 | 学习总结 + 掌握度变化 + 推荐模型 |
| 错误 | 错误提示 + 重试按钮 |

### 6.3 现有 Widget 复用

| Widget | 改造程度 |
|--------|---------|
| `TopFrameWidget` | 小改：显示知识点名称和掌握度 |
| `StepStageNavWidget` | 小改：根据 session.current_step 高亮 |
| `LearningDialogueWidget` | 大改：接入真实对话数据流 |
| `ActionOverlayWidget` | 大改：改为消息输入框 + 发送按钮 |
| `Step1-5 Widgets` | 保留 UI 结构，数据源改为 Provider |

---

## 七、掌握度更新逻辑

### 7.1 mastery_value 更新公式（知识点专用参数）

```
reward = base_r × (1 - mastery/100) × confidence × step_weight
penalty = base_p × (mastery/100) × confidence × step_weight

参数：
- base_r = 8
- base_p = 12
- step_weight: recall(记忆)=1.2, explain(理解)=1.0, apply(使用)=0.8
- confidence: 来自 S 场景表
```

### 7.2 学习完成后的掌握度变更规则

| 学习结果 | 掌握度变更 |
|---------|-----------|
| Step 4 检测全对 + Step 3 解释正确 | 升至 L4 区间起始值(60) |
| Step 4 检测全对，Step 3 未完全正确 | 升至 L3 区间(40-60) |
| Step 4 检测有错但最终通过 | 升至 L2-L3 区间 |
| Step 2 完成但 Step 4 未通过 | 保持/微升至 L1-L2 |
| 会话中途放弃 | 不变 |

### 7.3 时间衰减

```
14天内无活动：不衰减
14天后：mastery_value -= 0.3 × (days_inactive - 14)
衰减下限：max(mastery_value - 20, 5)
触发时机：每日凌晨定时任务
```

---

## 八、实施计划

### 8.1 Phase 1: 后端核心（优先）

| 任务 | 内容 | 新建/改造 |
|------|------|----------|
| ORM 模型 | LearningSession + LearningMessage | 新建 |
| Alembic 迁移 | 创建 learning_sessions + learning_messages 表 | 新建 |
| Schema 改造 | 扩展请求/响应 Schema | 改造 |
| PromptBuilder | LearningPromptBuilder 5 步模板 | 新建 |
| Service 改造 | start/chat/complete/get_session | 改造 |
| Router 改造 | 6 个端点 | 改造 |

### 8.2 Phase 2: 前端对接

| 任务 | 内容 |
|------|------|
| Provider 改造 | FutureProvider → StateNotifierProvider |
| 页面改造 | 接入真实会话数据流 |
| Widget 改造 | 对话列表 + 输入框 + 步骤导航 |
| 完成页面 | 掌握度变化 + 推荐模型展示 |

### 8.3 Phase 3: 闪卡集成

| 任务 | 内容 |
|------|------|
| 闪卡生成 | 学习完成后自动生成概念卡/条件卡/辨析卡 |
| 关联推荐 | 推荐关联模型的入口 |

### 8.4 依赖关系

```
Phase 1 后端核心 → Phase 2 前端对接 → Phase 3 闪卡集成
                                    ↗
LLM Client (已有，复用 AI 诊断) ──┘
```

### 8.5 验收标准

1. 通过 curl 完成一次完整 5 步知识点学习对话
2. 学习完成后 StudentMastery 表掌握度正确更新
3. 前端页面能展示真实对话流，步骤导航正确高亮
4. 会话中途退出后可恢复（GET session 返回活跃会话）
