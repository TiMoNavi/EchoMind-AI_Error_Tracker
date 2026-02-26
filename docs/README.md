# EchoMind 文档索引

> 本文件是 docs/ 目录的总索引，供开发者和 AI agent 快速定位所需文档。
>
> 最后更新：2026-02-25

---

## 目录结构

```
docs/
├── README.md              ← 你正在读的文件（总索引）
├── design/                ← 设计文档（AI 功能实现方案）
├── product/               ← 产品规格（核心框架、错因体系、架构主控）
├── customer/              ← 客户要求（需求框架、功能域、痛点分析）
├── api/                   ← API 文档（端点参考、OpenAPI 规范）
├── dev-guide/             ← 开发指南（技术栈、迭代计划、数据库设计）
├── education-data/        ← 教育数据需求（待外部填充的数据缺口清单）
├── testing/               ← 测试文档（UI 测试清单）
├── archive/               ← 归档（已弃用 + 阶段性过程文档）
│   ├── deprecated/        ← YBJ 弃用文档（早期技术方案，已过时）
│   ├── phase1-html/       ← 第一阶段：HTML 细化（含截图基准）
│   ├── phase2-migration/  ← 第二阶段：HTML → Flutter 迁移
│   └── phase3-polish/     ← 第三阶段：Flutter 美化（含页面说明）
└── assets/                ← 静态资源（截图等）
```

---

## 各目录说明

### `design/` — 设计文档
AI 功能模块的技术实现方案。

| 文件 | 说明 |
|------|------|
| [ai-diagnosis-implementation.md](design/ai-diagnosis-implementation.md) | AI 诊断功能实现方案 |

### `product/` — 产品规格
产品核心设计文档，定义业务逻辑、错因体系、架构约束。

| 文件 | 说明 |
|------|------|
| [architecture.md](product/architecture.md) | 产品架构主控文档：维度/名词/关系梳理，真相源 vs 派生视图 |
| [v1.0.md](product/v1.0.md) | 产品核心框架 v2.1（整合版），含 AI 诊断工作流 + 掌握度体系 |
| [v1.1part.md](product/v1.1part.md) | 物理错题分析大框架，完整错误编号体系 + AI 提示词拼接设计 |

### `customer/` — 客户要求
来自客户的原始需求、功能域划分、痛点评估。

| 文件 | 说明 |
|------|------|
| [core_framework_v2.0.md](customer/core_framework_v2.0.md) | 产品核心框架 v2.0，三 Tab 架构 + 12 功能域 |
| [功能域划分与数据关联.md](customer/功能域划分与数据关联.md) | 12 个功能域 + 6 个核心数据实体关联图 |
| [痛点分析与评估.md](customer/痛点分析与评估.md) | 产品痛点多维评分（痛感/付费/感知价值/实现难度） |
| [记录文件.md](customer/记录文件.md) | 客户对齐讨论记录（三 Tab、知识树层级等决策） |

### `api/` — API 文档
后端 API 端点参考和 OpenAPI 规范。

| 文件 | 说明 |
|------|------|
| [api-reference.md](api/api-reference.md) | API 参考文档，23 个端点详细说明（基址 8.130.16.212:8001） |
| [openapi.json](api/openapi.json) | OpenAPI 3.1 规范（自动生成） |
| [openapi-raw.json](api/openapi-raw.json) | OpenAPI 原始 JSON |

### `dev-guide/` — 开发指南
技术选型、迭代计划、团队分工、数据库设计。

| 文件 | 说明 |
|------|------|
| [01_技术栈选型.md](dev-guide/01_技术栈选型.md) | 前后端技术栈选型（Riverpod/Dio/FastAPI/PostgreSQL） |
| [02_四周迭代计划.md](dev-guide/02_四周迭代计划.md) | 1 个月 MVP 开发计划 |
| [03_三人分工方案.md](dev-guide/03_三人分工方案.md) | 3 人开发团队角色与分工 |
| [04_数据库Schema设计.md](dev-guide/04_数据库Schema设计.md) | PostgreSQL 数据库表设计 |

### `education-data/` — 教育数据需求
需要外部教研人员填充的数据缺口清单。

| 文件 | 说明 |
|------|------|
| [教育数据需求清单.md](education-data/教育数据需求清单.md) | 10 项教育数据缺口（四维能力算法、错因标签、知识点树等） |

### `testing/` — 测试文档
面向测试人员的操作指南。

| 文件 | 说明 |
|------|------|
| [ui-test-checklist.md](testing/ui-test-checklist.md) | 前端 UI 测试清单（面向非开发人员） |

### `archive/` — 归档
已完成阶段的过程文档和已弃用文档，保留供回溯参考。

| 子目录 | 说明 | 文件数 |
|--------|------|--------|
| `deprecated/` | YBJ 弃用文档（早期技术方案） | 8 |
| `phase1-html/` | 第一阶段：HTML 细化（需求梳理 + 组件截图） | 3 md + 80+ png |
| `phase2-migration/` | 第二阶段：HTML → Flutter（页面说明 + 提示词 + 完成记录） | 58 md |
| `phase3-polish/` | 第三阶段：Flutter 美化（21 个页面说明 + 截图） | 23 md |

---

## AI Agent 阅读指引

> 如果你是一个 AI agent，按以下场景快速定位需要阅读的文档：

| 你要做什么 | 先读这些 |
|-----------|---------|
| 理解产品全貌和业务逻辑 | `product/architecture.md` → `product/v1.0.md` |
| 了解客户需求和功能域 | `customer/core_framework_v2.0.md` → `customer/功能域划分与数据关联.md` |
| 开发后端 API | `api/api-reference.md` + `api/openapi.json` |
| 了解数据库结构 | `dev-guide/04_数据库Schema设计.md` |
| 了解技术栈和架构决策 | `dev-guide/01_技术栈选型.md` |
| 实现 AI 诊断/学习/训练功能 | `design/ai-diagnosis-implementation.md` → `product/v1.1part.md`（错因体系） |
| 填充教育数据 | `education-data/教育数据需求清单.md` |
| 测试前端 UI | `testing/ui-test-checklist.md` |
| 了解 Flutter 页面结构 | `archive/phase3-polish/21个flutter页面的分别说明文档/` |
| 查看 HTML 原型截图（对照基准） | `archive/phase1-html/html截图验证/` |
| 了解 HTML → Flutter 迁移契约 | `archive/phase2-migration/flutter-migration-contract.md` |

---

## 关键文档快速链接（高价值）

### 产品与需求（必读）
- [产品架构主控文档](product/architecture.md)
- [产品核心框架 v2.1](product/v1.0.md)
- [错题分析大框架](product/v1.1part.md)
- [客户核心框架 v2.0](customer/core_framework_v2.0.md)
- [功能域划分与数据关联](customer/功能域划分与数据关联.md)
- [痛点分析与评估](customer/痛点分析与评估.md)

### 技术与 API（开发必读）
- [API 参考文档](api/api-reference.md)
- [OpenAPI 规范](api/openapi.json)
- [技术栈选型](dev-guide/01_技术栈选型.md)
- [数据库 Schema 设计](dev-guide/04_数据库Schema设计.md)
- [AI 诊断实现方案](design/ai-diagnosis-implementation.md)

### 数据与测试
- [教育数据需求清单](education-data/教育数据需求清单.md)
- [UI 测试清单](testing/ui-test-checklist.md)

### Flutter 页面参考（第三阶段，最新）
- [页面索引](archive/phase3-polish/README.md)
- 21 个页面说明：`archive/phase3-polish/21个flutter页面的分别说明文档/`
