"""Model (解题模型) schemas."""
from pydantic import BaseModel


class ModelItem(BaseModel):
    id: str
    name: str
    description: str | None = None

    model_config = {"from_attributes": True}


class ModelSectionNode(BaseModel):
    section: str
    items: list[ModelItem]


class ModelChapterNode(BaseModel):
    chapter: str
    sections: list[ModelSectionNode]


class ModelDetail(ModelItem):
    chapter: str
    section: str
    prerequisite_kp_ids: list[str] | None = None
    confusion_group_ids: list[str] | None = None
    mastery_level: int | None = None
