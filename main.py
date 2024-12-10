from fastapi import FastAPI

from api import users, portfolios
from db.db_setup import engine
from db.models import user, portfolio

user.Base.metadata.create_all(bind=engine)
portfolio.Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Fast API Made4U",
    description="API for Made4U webapp",
    version="0.0.1"
)

app.include_router(users.router)
app.include_router(portfolios.router)
