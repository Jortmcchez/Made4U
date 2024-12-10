from typing import Optional, List

import fastapi
from fastapi import Depends, HTTPException
from sqlalchemy.orm import Session

from db.db_setup import get_db
from pydantic_schemas.portfolio import PortfolioCreate, Portfolio
from api.utils.portfolios import get_portfolio, get_portfolio_by_artist_id, get_portfolios, create_portfolios

router = fastapi.APIRouter()


@router.get("/portfolios", response_model=List[Portfolio])
async def read_portfolios(skip: int =0, limit: int = 100, db: Session = Depends(get_db)):
    portfolios = get_portfolios(db, skip=skip, limit=limit)
    return portfolios

@router.post("/portfolios", response_model=Portfolio, status_code=201)
async def create_new_portfolio(portfolio: PortfolioCreate, db: Session = Depends(get_db)):
    return create_portfolios(db=db, portfolio=portfolio)

@router.get("/portfolios/{artist_id}", response_model=Portfolio)
async def read_portfolio(artist_id: int, db: Session = Depends(get_db)):
    db_portfolio = get_portfolio_by_artist_id(db=db, artist_id=artist_id)
    if db_portfolio is None:
        raise HTTPException(status_code=404, detail="Portfolio not found")
    return db_portfolio

@router.get("/portfolios/{portfolio_id}", response_model=List[Portfolio])
async def read_portfolio(portfolio_id: int, db: Session = Depends(get_db)):
    db_portfolio = get_portfolio(db=db, portfolio_id=portfolio_id)
    if db_portfolio is None:
        raise HTTPException(status_code=404, detail="Portfolio not found")
    return db_portfolio