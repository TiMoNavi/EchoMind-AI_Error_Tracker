"""Auth router — register / login / me."""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.deps import get_current_user
from app.core.security import hash_password, verify_password, create_access_token
from app.models.student import Student
from app.schemas.auth import RegisterRequest, LoginRequest, TokenResponse, UserResponse

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/register", response_model=TokenResponse, status_code=201)
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
    return TokenResponse(access_token=create_access_token(str(student.id)))


@router.post("/login", response_model=TokenResponse)
async def login(req: LoginRequest, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Student).where(Student.phone == req.phone))
    user = result.scalar_one_or_none()
    if not user or not verify_password(req.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    return TokenResponse(access_token=create_access_token(str(user.id)))


@router.get("/me", response_model=UserResponse)
async def me(user: Student = Depends(get_current_user)):
    return UserResponse(
        id=str(user.id),
        phone=user.phone,
        nickname=user.nickname,
        region_id=user.region_id,
        subject=user.subject,
        target_score=user.target_score,
        predicted_score=user.predicted_score,
    )
