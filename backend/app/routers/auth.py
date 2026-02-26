"""Auth router — register / login / me."""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.deps import get_current_user
from app.core.security import hash_password, verify_password, create_access_token
from app.models.student import Student
from app.schemas.auth import RegisterRequest, LoginRequest, AuthResponse, UserResponse, ProfileUpdate

router = APIRouter(prefix="/auth", tags=["认证"])


def _to_user_response(u: Student) -> UserResponse:
    return UserResponse(
        id=str(u.id), phone=u.phone, nickname=u.nickname,
        avatar_url=u.avatar_url,
        region_id=u.region_id, subject=u.subject,
        target_score=u.target_score, predicted_score=u.predicted_score,
    )


@router.post("/register", response_model=AuthResponse, status_code=201)
async def register(req: RegisterRequest, db: AsyncSession = Depends(get_db)):
    exists = await db.execute(select(Student).where(Student.phone == req.phone))
    if exists.scalar_one_or_none():
        raise HTTPException(status_code=409, detail="Phone already registered")

    student = Student(
        phone=req.phone,
        password_hash=hash_password(req.password),
        nickname=req.nickname,
        region_id=req.region_id,
        subject=req.subject,
        target_score=req.target_score,
    )
    db.add(student)
    await db.commit()
    await db.refresh(student)
    token = create_access_token(str(student.id))
    return AuthResponse(
        access_token=token,
        user=_to_user_response(student),
    )


@router.post("/login", response_model=AuthResponse)
async def login(req: LoginRequest, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Student).where(Student.phone == req.phone))
    user = result.scalar_one_or_none()
    if not user or not verify_password(req.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    token = create_access_token(str(user.id))
    return AuthResponse(
        access_token=token,
        user=_to_user_response(user),
    )


@router.get("/me", response_model=UserResponse)
async def me(user: Student = Depends(get_current_user)):
    return _to_user_response(user)


@router.put("/profile", response_model=UserResponse)
async def update_profile(
    req: ProfileUpdate,
    user: Student = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """更新个人资料，仅更新传入的非 None 字段。"""
    update_data = req.model_dump(exclude_unset=True)
    if not update_data:
        raise HTTPException(status_code=400, detail="No fields to update")
    for field, value in update_data.items():
        setattr(user, field, value)
    await db.commit()
    await db.refresh(user)
    return _to_user_response(user)
