"""Seed script — insert sample data for all core tables (idempotent via merge)."""
import asyncio
import uuid

from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker

from app.core.config import settings
from app.core.database import Base
from app.core.security import hash_password
from app.models.knowledge_point import KnowledgePoint
from app.models.model import Model
from app.models.regional_template import RegionalTemplate
from app.models.student import Student
from app.models.question import Question
from app.models.student_mastery import StudentMastery

# 固定 UUID 以支持幂等
TEST_STUDENT_ID = uuid.UUID("00000000-0000-0000-0000-000000000001")
TEST_QUESTION_IDS = [
    uuid.UUID("00000000-0000-0000-0000-000000000101"),
    uuid.UUID("00000000-0000-0000-0000-000000000102"),
    uuid.UUID("00000000-0000-0000-0000-000000000103"),
]

KNOWLEDGE_POINTS = [
    {"id": "kp_coulomb_law", "name": "库仑定律", "chapter": "静电场", "section": "电荷与库仑定律", "conclusion_level": 1, "related_model_ids": ["model_coulomb_balance"]},
    {"id": "kp_electric_field", "name": "电场强度", "chapter": "静电场", "section": "电场", "conclusion_level": 1, "related_model_ids": ["model_electric_field_calc"]},
    {"id": "kp_electric_potential", "name": "电势与电势差", "chapter": "静电场", "section": "电势", "conclusion_level": 1, "related_model_ids": []},
    {"id": "kp_capacitor", "name": "电容器", "chapter": "静电场", "section": "电容器", "conclusion_level": 2, "related_model_ids": ["model_capacitor_change"]},
    {"id": "kp_newton_second", "name": "牛顿第二定律", "chapter": "力学", "section": "牛顿运动定律", "conclusion_level": 1, "related_model_ids": ["model_newton_app", "model_plate_motion"]},
    {"id": "kp_friction", "name": "摩擦力", "chapter": "力学", "section": "力的分析", "conclusion_level": 1, "related_model_ids": ["model_plate_motion"]},
    {"id": "kp_uniform_motion", "name": "匀变速直线运动", "chapter": "力学", "section": "运动学", "conclusion_level": 1, "related_model_ids": ["model_kinematics"]},
    {"id": "kp_energy_conservation", "name": "能量守恒定律", "chapter": "力学", "section": "功与能", "conclusion_level": 1, "related_model_ids": ["model_energy_method"]},
    {"id": "kp_momentum", "name": "动量定理", "chapter": "力学", "section": "动量", "conclusion_level": 1, "related_model_ids": ["model_momentum_collision"]},
    {"id": "kp_magnetic_force", "name": "安培力与洛伦兹力", "chapter": "磁场", "section": "磁场力", "conclusion_level": 1, "related_model_ids": ["model_charged_particle"]},
]

MODELS = [
    {"id": "model_coulomb_balance", "name": "库仑力平衡", "chapter": "静电场", "section": "库仑定律应用", "prerequisite_kp_ids": ["kp_coulomb_law"]},
    {"id": "model_electric_field_calc", "name": "电场强度计算", "chapter": "静电场", "section": "电场计算", "prerequisite_kp_ids": ["kp_electric_field"]},
    {"id": "model_capacitor_change", "name": "电容器变化分析", "chapter": "静电场", "section": "电容器", "prerequisite_kp_ids": ["kp_capacitor", "kp_electric_field"]},
    {"id": "model_newton_app", "name": "牛顿第二定律应用", "chapter": "力学", "section": "牛顿运动定律", "prerequisite_kp_ids": ["kp_newton_second"]},
    {"id": "model_plate_motion", "name": "板块运动", "chapter": "力学", "section": "牛顿运动定律", "prerequisite_kp_ids": ["kp_newton_second", "kp_friction"]},
    {"id": "model_kinematics", "name": "运动学公式应用", "chapter": "力学", "section": "运动学", "prerequisite_kp_ids": ["kp_uniform_motion"]},
    {"id": "model_energy_method", "name": "能量法解题", "chapter": "力学", "section": "功与能", "prerequisite_kp_ids": ["kp_energy_conservation"]},
    {"id": "model_momentum_collision", "name": "动量守恒与碰撞", "chapter": "力学", "section": "动量", "prerequisite_kp_ids": ["kp_momentum", "kp_energy_conservation"]},
    {"id": "model_charged_particle", "name": "带电粒子在磁场中运动", "chapter": "磁场", "section": "磁场力应用", "prerequisite_kp_ids": ["kp_magnetic_force", "kp_uniform_motion"]},
]

TEMPLATES = [
    {
        "id": "tianjin_physics_70",
        "region_id": "tianjin", "subject": "physics", "target_score": 70, "total_score": 100,
        "key_message": "70分=选择题最多错2个+大题前两道拿满，你做得到",
        "vs_lower": "比60分多要求：大题第一题全拿+选择多对2道",
        "vs_higher": "比80分允许放弃：大题第三题、多选最后一道",
        "exam_structure": [
            {
                "section_name": "选择题（单选）",
                "questions": [
                    {"question_number": i, "max_score": 3, "difficulty": "easy" if i <= 4 else "medium",
                     "typical_models": ["model_kinematics"] if i <= 2 else ["model_newton_app"],
                     "typical_kps": ["kp_uniform_motion"] if i <= 2 else ["kp_newton_second"]}
                    for i in range(1, 7)
                ],
            },
            {
                "section_name": "选择题（多选）",
                "questions": [
                    {"question_number": i, "max_score": 3, "difficulty": "medium" if i == 7 else "hard",
                     "typical_models": ["model_energy_method"], "typical_kps": ["kp_energy_conservation"]}
                    for i in range(7, 9)
                ],
            },
            {
                "section_name": "实验题",
                "questions": [
                    {"question_number": 9, "max_score": 8, "difficulty": "medium",
                     "typical_models": [], "typical_kps": ["kp_newton_second"]},
                    {"question_number": 10, "max_score": 7, "difficulty": "medium",
                     "typical_models": [], "typical_kps": ["kp_electric_field"]},
                ],
            },
            {
                "section_name": "计算题",
                "questions": [
                    {"question_number": 11, "max_score": 12, "difficulty": "medium",
                     "typical_models": ["model_newton_app", "model_kinematics"],
                     "typical_kps": ["kp_newton_second", "kp_uniform_motion"]},
                    {"question_number": 12, "max_score": 14, "difficulty": "hard",
                     "typical_models": ["model_energy_method", "model_momentum_collision"],
                     "typical_kps": ["kp_energy_conservation", "kp_momentum"]},
                    {"question_number": 13, "max_score": 18, "difficulty": "extreme",
                     "typical_models": ["model_charged_particle", "model_plate_motion"],
                     "typical_kps": ["kp_magnetic_force", "kp_newton_second"]},
                ],
            },
            {
                "section_name": "选做题",
                "questions": [
                    {"question_number": 14, "max_score": 15, "difficulty": "medium",
                     "typical_models": ["model_energy_method"],
                     "typical_kps": ["kp_energy_conservation"]},
                ],
            },
        ],
        "question_strategies": [
            {"question_range": "选择1-6（单选）", "max_score": 18, "target_score": 18,
             "attitude": "must", "note": "全对", "display_text": "这些你绝对能做到"},
            {"question_range": "选择7-8（多选）", "max_score": 6, "target_score": 3,
             "attitude": "try", "note": "稳选一半", "display_text": "多选题稳选一半"},
            {"question_range": "实验题", "max_score": 15, "target_score": 10,
             "attitude": "try", "note": "基础实验必拿", "display_text": "基础实验你能拿到"},
            {"question_range": "大题1", "max_score": 12, "target_score": 12,
             "attitude": "must", "note": "全拿", "display_text": "你有能力写出来"},
            {"question_range": "大题2", "max_score": 14, "target_score": 10,
             "attitude": "try", "note": "前两问必做", "display_text": "前两问争取拿满"},
            {"question_range": "大题3", "max_score": 18, "target_score": 5,
             "attitude": "skip", "note": "写已知+第一步", "display_text": "写出已知量就有分"},
            {"question_range": "选做题", "max_score": 15, "target_score": 12,
             "attitude": "must", "note": "选做题相对简单", "display_text": "选做题你一定能拿"},
        ],
        "diagnosis_path": [
            {"tier": 1, "model_id": "model_newton_app", "score_impact": "12-18分",
             "reason": "大题第一/二题核心", "skippable": False},
            {"tier": 1, "model_id": "model_kinematics", "score_impact": "12分",
             "reason": "大题第一题基础", "skippable": False},
            {"tier": 1, "model_id": "model_energy_method", "score_impact": "14-15分",
             "reason": "大题第二题+选做题", "skippable": False},
            {"tier": 2, "model_id": "model_plate_motion", "score_impact": "6-12分",
             "reason": "选择高频+大题可能", "skippable": False},
            {"tier": 2, "model_id": "model_coulomb_balance", "score_impact": "3-6分",
             "reason": "选择高频", "skippable": False},
            {"tier": 3, "model_id": "model_charged_particle", "score_impact": "3-6分",
             "reason": "大题第三题（可放弃）", "skippable": True},
        ],
    },
]


async def seed():
    engine = create_async_engine(settings.database_url)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    session_factory = async_sessionmaker(engine, expire_on_commit=False)
    async with session_factory() as session:
        # 知识点 + 模型 + 地区模板（merge 实现幂等）
        for kp in KNOWLEDGE_POINTS:
            await session.merge(KnowledgePoint(**kp))
        for m in MODELS:
            await session.merge(Model(**m))
        for t in TEMPLATES:
            await session.merge(RegionalTemplate(**t))

        # 测试学生
        await session.merge(Student(
            id=TEST_STUDENT_ID,
            phone="13800000001",
            password_hash=hash_password("test1234"),
            nickname="测试学生",
            region_id="tianjin",
            subject="physics",
            target_score=70,
        ))

        # 测试题目（3 条）
        for i, qid in enumerate(TEST_QUESTION_IDS):
            await session.merge(Question(
                id=qid,
                student_id=TEST_STUDENT_ID,
                source="manual",
                image_url=f"https://example.com/q{i+1}.png",
                is_correct=[True, False, None][i],
                diagnosis_status="pending",
            ))

        # 测试掌握度（2 条：1 个知识点 + 1 个模型）
        await session.merge(StudentMastery(
            id=uuid.UUID("00000000-0000-0000-0000-000000000201"),
            student_id=TEST_STUDENT_ID,
            target_type="kp",
            target_id="kp_newton_second",
            current_level=3,
            mastery_value=71.4,
            error_count=2,
            correct_count=5,
            is_unstable=False,
        ))
        await session.merge(StudentMastery(
            id=uuid.UUID("00000000-0000-0000-0000-000000000202"),
            student_id=TEST_STUDENT_ID,
            target_type="model",
            target_id="model_plate_motion",
            current_level=1,
            mastery_value=20.0,
            error_count=4,
            correct_count=1,
            is_unstable=True,
        ))

        await session.commit()

    await engine.dispose()
    print("Seed complete (idempotent).")


if __name__ == "__main__":
    asyncio.run(seed())
