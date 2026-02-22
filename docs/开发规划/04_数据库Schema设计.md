# 数据库Schema设计（PostgreSQL）

> 基于 core_framework_v2.0.md 审计补充数据模型 + Section 二十九标签字段

---

## 表1：students（学生）

```sql
CREATE TABLE students (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone         VARCHAR(20) UNIQUE NOT NULL,
    nickname      VARCHAR(50),
    avatar_url    TEXT,

    -- 注册信息
    region_id     VARCHAR(30) NOT NULL,        -- 省份/城市，如 'tianjin'
    subject       VARCHAR(20) NOT NULL,        -- 科目，如 'physics'
    target_score  INT NOT NULL,                -- 目标裸分

    -- 卷面策略（注册时生成，目标分变更时重算）
    exam_strategy JSONB,                       -- question_strategies数组

    -- 三维画像（注册诊断初始化，日常更新）
    formula_memory_rate   FLOAT DEFAULT 0,     -- 公式记忆度 0-1
    model_identify_rate   FLOAT DEFAULT 0,     -- 模型识别力 0-1
    calculation_accuracy  FLOAT DEFAULT 0,     -- 计算准确度 0-1
    reading_accuracy      FLOAT DEFAULT 0,     -- 审题正确率 0-1

    -- 闭环统计
    total_closures_today  INT DEFAULT 0,
    total_closures_week   INT DEFAULT 0,

    -- 预测
    predicted_score       FLOAT,
    last_prediction_time  TIMESTAMPTZ,

    created_at    TIMESTAMPTZ DEFAULT now(),
    updated_at    TIMESTAMPTZ DEFAULT now()
);
```

---

## 表2：knowledge_points（知识点）

```sql
CREATE TABLE knowledge_points (
    id                VARCHAR(50) PRIMARY KEY,   -- 如 'kp_electrostatic_force'
    name              VARCHAR(100) NOT NULL,
    chapter           VARCHAR(100) NOT NULL,     -- Level 1：章
    section           VARCHAR(100) NOT NULL,     -- Level 2：节
    conclusion_level  SMALLINT DEFAULT 1,        -- 1=一级结论(需深入理解) 2=二级结论(记住即可)
    related_model_ids TEXT[],                    -- 关联模型ID数组
    description       TEXT,
    created_at        TIMESTAMPTZ DEFAULT now()
);
```

---

## 表3：models（解题模型）

```sql
CREATE TABLE models (
    id                VARCHAR(50) PRIMARY KEY,   -- 如 'model_plate_motion'
    name              VARCHAR(100) NOT NULL,
    chapter           VARCHAR(100) NOT NULL,     -- Level 1：章
    section           VARCHAR(100) NOT NULL,     -- Level 2：节
    prerequisite_kp_ids TEXT[],                  -- 前置知识点ID数组
    confusion_group_ids TEXT[],                  -- 所属易混组ID
    description       TEXT,
    created_at        TIMESTAMPTZ DEFAULT now()
);
```

---

## 表4：student_mastery（学生掌握度 — 核心状态表）

> 每个学生×每个知识点/模型 = 一行。这是域6状态引擎的核心。

```sql
CREATE TABLE student_mastery (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id      UUID NOT NULL REFERENCES students(id),
    target_type     VARCHAR(10) NOT NULL,        -- 'kp' 或 'model'
    target_id       VARCHAR(50) NOT NULL,         -- knowledge_point.id 或 model.id

    -- Section 二十九：完整标签字段集
    current_level       SMALLINT DEFAULT 0,       -- 0-5 当前掌握度
    peak_level          SMALLINT DEFAULT 0,       -- 0-5 历史最高
    last_active         TIMESTAMPTZ,              -- 最后交互时间
    error_count         INT DEFAULT 0,
    correct_count       INT DEFAULT 0,
    recent_results      BOOLEAN[] DEFAULT '{}',   -- 最近4次对错
    last_error_subtype  VARCHAR(30),              -- identify_wrong/decide_wrong/step_wrong/...
    is_unstable         BOOLEAN DEFAULT FALSE,    -- 仅model有效
    next_retest_date    TIMESTAMPTZ,              -- 仅model：L4后延时复测日期

    created_at      TIMESTAMPTZ DEFAULT now(),
    updated_at      TIMESTAMPTZ DEFAULT now(),

    UNIQUE(student_id, target_type, target_id)
);

CREATE INDEX idx_mastery_student ON student_mastery(student_id);
CREATE INDEX idx_mastery_level ON student_mastery(student_id, current_level);
```

---

## 表5：questions（题目）

```sql
CREATE TABLE questions (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id        UUID NOT NULL REFERENCES students(id),
    source            VARCHAR(20) NOT NULL,       -- homework / practice / exam
    upload_batch_id   UUID,                       -- 属于哪次上传
    image_url         TEXT,

    is_correct            BOOLEAN,                -- 学生标注的对错
    primary_model_id      VARCHAR(50),            -- 主归属模型（AI打标签）
    related_kp_ids        TEXT[],                 -- 关联知识点
    exam_question_number  INT,                    -- 高考题号（仅考试卷子）

    -- 诊断结果
    diagnosis_status      VARCHAR(20) DEFAULT 'pending',  -- pending/diagnosed/skipped
    diagnosis_result      JSONB,                  -- {error_type, error_subtype, confidence}

    created_at  TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_questions_student ON questions(student_id, created_at DESC);
CREATE INDEX idx_questions_model ON questions(primary_model_id);
```

---

## 表6：regional_templates（地区卷面模板）

```sql
CREATE TABLE regional_templates (
    id              VARCHAR(50) PRIMARY KEY,     -- 如 'tianjin_physics_70'
    region_id       VARCHAR(30) NOT NULL,
    subject         VARCHAR(20) NOT NULL,
    target_score    INT NOT NULL,
    total_score     INT NOT NULL,

    exam_structure      JSONB NOT NULL,          -- 卷面结构（题型+题号+分值+难度+关联模型）
    question_strategies JSONB NOT NULL,          -- 分数档策略（must/try/skip）
    diagnosis_path      JSONB NOT NULL,          -- 诊断路径（tier排序+测试题ID）

    created_at  TIMESTAMPTZ DEFAULT now(),

    UNIQUE(region_id, subject, target_score)
);
```

---

## 表7：upload_batches（上传批次）

```sql
CREATE TABLE upload_batches (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id  UUID NOT NULL REFERENCES students(id),
    source      VARCHAR(20) NOT NULL,   -- homework / practice / exam
    image_count INT DEFAULT 0,
    created_at  TIMESTAMPTZ DEFAULT now()
);
```

---

## 表8：confusion_groups（易混组 — 教研预设）

```sql
CREATE TABLE confusion_groups (
    id               VARCHAR(50) PRIMARY KEY,
    model_ids        TEXT[] NOT NULL,          -- 组内模型ID
    comparison_table JSONB,                    -- {headers:[], rows:[[]]}
    created_at       TIMESTAMPTZ DEFAULT now()
);
```

---

## 设计说明

1. **student_mastery 是系统心脏**：域6状态引擎的所有读写都在这张表。索引设计优先保证 `student_id + current_level` 的查询性能（推荐排序依赖）。

2. **JSONB 用于半结构化数据**：exam_strategy、diagnosis_result、exam_structure 等字段结构复杂且可能演化，用 JSONB 比拆表更灵活。

3. **闪卡表(flashcards)暂不建**：MVP不做闪卡功能，第二个月再加。

4. **Level含义速查**：
   - 知识点：L0=未发现, L1=记不住, L2=理解不深, L3=使用出错, L4=能用, L5=稳定
   - 模型：L0=未发现, L1=建模卡住, L2=列式卡住, L3=执行卡住, L4=做对过, L5=稳定
