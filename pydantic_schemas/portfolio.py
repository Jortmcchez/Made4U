from pydantic import BaseModel
from enum import Enum

class PortfolioBase(BaseModel):
    artist_id: int
    #art_id = int


class PortfolioCreate(PortfolioBase):
    ...

class Portfolio(PortfolioBase):
    id: int

    class Config:
        orm_mode = True

