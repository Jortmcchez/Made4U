from sqlalchemy.orm import Session

from db.models.user import User
from pydantic_schemas.user import UserCreate

def get_user(db: Session, user_id: int):
    return db.query(User).filter(User.id == user_id).first()
    # i want to query user table by this information and take the first record
    # filter by default returns a list

def get_user_by_email(db: Session, email: str):
    return db.query(User).filter(User.email == email).first()

def get_user_by_username(db: Session, username: str):
    return db.query(User).filter(User.username == username).first()

def get_users(db: Session, skip: int = 0, limit: int = 100):
    return db.query(User).offset(skip).limit(limit).all()

def create_users(db: Session, user: UserCreate):
    db_user = User(
        email =user.email,
        username = user.username,
        password = user.password,
        role = user.role,
        first_name = user.first_name,
        last_name = user.last_name
        )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user