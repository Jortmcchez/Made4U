from pydantic import BaseModel
from enum import Enum

class UserBase(BaseModel):
    email: str
    username: str
    password:str
    role: int
    first_name: str
    last_name: str


class UserCreate(UserBase):
    ...

class User(UserBase):
    id: int

    class Config:
        orm_mode = True

