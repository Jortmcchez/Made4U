from pydantic import BaseModel
from enum import Enum

class UserBase(BaseModel):
    email: str
    username: str
    password:str
    role: int


class UserCreate(UserBase):
    ...

class User(UserBase):
    id: int

    class Config:
        orm_mode = True

