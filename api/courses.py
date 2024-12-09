from typing import Optional, List
import fastapi
from pydantic import BaseModel

router = fastapi.APIRouter()

@router.get("/courses")
async def read_courses():
    return {"courses": []}

@router.post("/courses")
async def creare_course_api():
    return {"courses": []}

@router.get("/courses/{id}")
async def read_course():
    return {"courses": []}

@router.delete("/courses/{id}")
async def delete_course():
    return {"courses": []}

@router.get("/courses/{id}")
async def read_course_sections():
    return {"courses": []}