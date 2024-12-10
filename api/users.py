from typing import Optional, List

import fastapi
from fastapi import Depends, HTTPException
from sqlalchemy.orm import Session

from db.db_setup import get_db
from pydantic_schemas.user import UserCreate, User
from api.utils.users import get_user, get_user_by_email, get_users, create_users

router = fastapi.APIRouter()


@router.get("/users", response_model=List[User])
async def read_users(skip: int =0, limit: int = 100, db: Session = Depends(get_db)):
    users = get_users(db, skip=skip, limit=limit)
    return users

@router.post("/users")
async def create_new_user(user: UserCreate, db: Session = Depends(get_db)):
    return create_users(db=db, user=user)

# @router.get("/users/{id}")
# async def get_user(id: int):
#     return { "user": users[id]}