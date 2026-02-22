"""Knowledge point schemas."""
from pydantic import BaseModel


class KnowledgePointItem(BaseModel):
    id: str
    name: str
    conclusion_level: int
    description: str | None = None

    model_config = {"from_attributes": True}


class SectionNode(BaseModel):
    section: str
    items: list[KnowledgePointItem]


class ChapterNode(BaseModel):
    chapter: str
    sections: list[SectionNode]


class KnowledgePointDetail(KnowledgePointItem):
    chapter: str
    section: str
    related_model_ids: list[str] | None = None
    mastery_level: int | None = None
    mastery_value: float | None = None
    error_count: int = 0
    correct_count: int = 0
