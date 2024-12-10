from sqlalchemy.orm import Session

from db.models.portfolio import Portfolio
from pydantic_schemas.portfolio import PortfolioCreate

def get_portfolio(db: Session, portfolio_id: int):
    return db.query(Portfolio).filter(Portfolio.id == portfolio_id).first()
    # i want to query user table by this information and take the first record
    # filter by default returns a list

def get_portfolio_by_artist_id(db: Session, artist_id: int):
    return db.query(Portfolio).filter(Portfolio.artist_id == artist_id).first()

# def get_portfolio_by_art_id(db: Session, art_id: int):
#     return db.query(Portfolio).filter(Portfolio.art_id == art_id).first()

def get_portfolios(db: Session, skip: int = 0, limit: int = 100):
    return db.query(Portfolio).offset(skip).limit(limit).all()

def create_portfolios(db: Session, portfolio: PortfolioCreate):
    db_portfolio = Portfolio(
        artist_id = portfolio.artist_id
        #art_id = portfolio.art_id,
        )
    db.add(db_portfolio)
    db.commit()
    db.refresh(db_portfolio)
    return db_portfolio