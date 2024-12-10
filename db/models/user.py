import enum

from sqlalchemy import Boolean, Column, ForeignKey, Integer, String, Enum, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql.expression import null

from ..db_setup import Base

class Role(enum.IntEnum):
    Artist = 0
    Commissioner = 1
    Moderator = 2

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(100), nullable=False)
    username = Column(String(50), nullable=False)
    password = Column(String(100), nullable=False)
    role = Column(Enum(Role))