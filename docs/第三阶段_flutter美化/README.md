# 第三阶段：Flutter 页面说明文档

## 概述

共 21 个页面（20 个路由 + 1 个 community-detail 子页面），104 个 dart 文件。
截图采集方式：Windows 桌面端 integration test，390x844 视口。
共生成 91 张截图（21 张整页 + 70 张组件）。

## 页面文档索引

| 序号 | 页面 | 路由 | 组件数 | 文档 |
|------|------|------|--------|------|
| 01 | 首页 | `/` | 5 | [01_home_首页.md](21个flutter页面的分别说明文档/01_home_首页.md) |
| 02 | 社区 | `/community` | 4 | [02_community_社区.md](21个flutter页面的分别说明文档/02_community_社区.md) |
| 03 | 社区详情 | `/community-detail` | 1 | [03_community-detail_社区详情.md](21个flutter页面的分别说明文档/03_community-detail_社区详情.md) |
| 04 | 全局知识点 | `/global-knowledge` | 2 | [04_global-knowledge_全局知识点.md](21个flutter页面的分别说明文档/04_global-knowledge_全局知识点.md) |
| 05 | 全局模型 | `/global-model` | 2 | [05_global-model_全局模型.md](21个flutter页面的分别说明文档/05_global-model_全局模型.md) |
| 06 | 全局高考卷 | `/global-exam` | 4 | [06_global-exam_全局高考卷.md](21个flutter页面的分别说明文档/06_global-exam_全局高考卷.md) |
| 07 | 记忆 | `/memory` | 3 | [07_memory_记忆.md](21个flutter页面的分别说明文档/07_memory_记忆.md) |
| 08 | 闪卡复习 | `/flashcard-review` | 2 | [08_flashcard-review_闪卡复习.md](21个flutter页面的分别说明文档/08_flashcard-review_闪卡复习.md) |
| 09 | 单题聚合 | `/question-aggregate` | 4 | [09_question-aggregate_单题聚合.md](21个flutter页面的分别说明文档/09_question-aggregate_单题聚合.md) |
| 10 | 题目详情 | `/question-detail` | 5 | [10_question-detail_题目详情.md](21个flutter页面的分别说明文档/10_question-detail_题目详情.md) |
| 11 | AI诊断 | `/ai-diagnosis` | 3 | [11_ai-diagnosis_AI诊断.md](21个flutter页面的分别说明文档/11_ai-diagnosis_AI诊断.md) |
| 12 | 模型详情 | `/model-detail` | 5 | [12_model-detail_模型详情.md](21个flutter页面的分别说明文档/12_model-detail_模型详情.md) |
| 13 | 模型训练 | `/model-training` | 10 | [13_model-training_模型训练.md](21个flutter页面的分别说明文档/13_model-training_模型训练.md) |
| 14 | 知识点详情 | `/knowledge-detail` | 4 | [14_knowledge-detail_知识点详情.md](21个flutter页面的分别说明文档/14_knowledge-detail_知识点详情.md) |
| 15 | 知识点学习 | `/knowledge-learning` | 9 | [15_knowledge-learning_知识点学习.md](21个flutter页面的分别说明文档/15_knowledge-learning_知识点学习.md) |
| 16 | 预测中心 | `/prediction-center` | 5 | [16_prediction-center_预测中心.md](21个flutter页面的分别说明文档/16_prediction-center_预测中心.md) |
| 17 | 上传历史 | `/upload-history` | 3 | [17_upload-history_上传历史.md](21个flutter页面的分别说明文档/17_upload-history_上传历史.md) |
| 18 | 周复盘 | `/weekly-review` | 5 | [18_weekly-review_周复盘.md](21个flutter页面的分别说明文档/18_weekly-review_周复盘.md) |
| 19 | 我的 | `/profile` | 6 | [19_profile_我的.md](21个flutter页面的分别说明文档/19_profile_我的.md) |
| 20 | 上传菜单 | `/upload-menu` | 2* | [20_upload-menu_上传菜单.md](21个flutter页面的分别说明文档/20_upload-menu_上传菜单.md) |
| 21 | 学习策略 | `/register-strategy` | 2* | [21_register-strategy_学习策略.md](21个flutter页面的分别说明文档/21_register-strategy_学习策略.md) |

> *标注的页面当前为占位实现，widget 文件存在但未被页面引用

## 截图目录

截图存放在 `flutter截图验证/` 目录下，每个页面一个子目录：

```
flutter截图验证/
├── home/          (full/ + components/)
├── community/     (full/ + components/)
├── community-detail/ (full/)
├── global-knowledge/ (full/ + components/)
├── global-model/  (full/ + components/)
├── global-exam/   (full/ + components/)
├── memory/        (full/ + components/)
├── flashcard-review/ (full/ + components/)
├── question-aggregate/ (full/ + components/)
├── question-detail/ (full/ + components/)
├── ai-diagnosis/  (full/ + components/)
├── model-detail/  (full/ + components/)
├── model-training/ (full/ + components/)
├── knowledge-detail/ (full/ + components/)
├── knowledge-learning/ (full/ + components/)
├── prediction-center/ (full/ + components/)
├── upload-history/ (full/ + components/)
├── weekly-review/ (full/ + components/)
├── profile/       (full/ + components/)
├── upload-menu/   (full/)
└── register-strategy/ (full/)
```

## 相关文件

- 截图脚本: `flutter前端/echomind_app/integration_test/screenshot_stage3_test.dart`
- 规划文档: [第三阶段规划_flutter页面说明文档生成.md](第三阶段规划_flutter页面说明文档生成.md)
