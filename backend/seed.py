"""Seed script — insert sample knowledge points, models, and regional templates."""
import asyncio

from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker

from app.core.config import settings
from app.core.database import Base
from app.models.knowledge_point import KnowledgePoint
from app.models.model import Model
from app.models.regional_template import RegionalTemplate
from app.models.confusion_group import ConfusionGroup

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
        "exam_structure": {"sections": [
            {"type": "choice", "numbers": list(range(1, 9)), "score_each": 4},
            {"type": "fill", "numbers": [9, 10], "score_each": 6},
            {"type": "big", "numbers": [11, 12, 13], "score_each": 16},
        ]},
        "question_strategies": {"strategies": [
            {"number": 1, "priority": "must", "model_ids": ["model_kinematics"]},
            {"number": 5, "priority": "must", "model_ids": ["model_newton_app"]},
            {"number": 8, "priority": "skip", "model_ids": ["model_charged_particle"]},
        ]},
        "diagnosis_path": {"tiers": [
            {"tier": 1, "model_ids": ["model_newton_app", "model_kinematics", "model_energy_method"]},
            {"tier": 2, "model_ids": ["model_plate_motion", "model_coulomb_balance"]},
        ]},
    },
]


async def seed():
    engine = create_async_engine(settings.database_url)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    session_factory = async_sessionmaker(engine, expire_on_commit=False)
    async with session_factory() as session:
        for kp in KNOWLEDGE_POINTS:
            session.add(KnowledgePoint(**kp))
        for m in MODELS:
            session.add(Model(**m))
        for t in TEMPLATES:
            session.add(RegionalTemplate(**t))
        await session.commit()

    await engine.dispose()
    print("Seed complete.")


if __name__ == "__main__":
    asyncio.run(seed())
