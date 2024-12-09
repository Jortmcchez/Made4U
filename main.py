from typing import Optional, List
from fastapi import FastAPI, Path, Query
from pydantic import BaseModel

from api import users, courses, sections

app = FastAPI(
    title="Fast API Made4U",
    description="API for Made4U webapp",
    version="0.0.1"
)

app.include_router(users.router)
app.include_router(sections.router)
app.include_router(courses.router)