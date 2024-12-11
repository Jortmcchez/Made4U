DEPENDENCIES 
uvicorn fastapi pydantic sqlalchemy psycopg2-binary alembic sqlalchemy-utils

CONNECT BACKEND
Add Database URL in alembic.ini and db_setup

ESTABLISH BACKEND
alembic init alembic
alembic revision autogenerate
alembic upgrade head

START SERVER
uvicorn main:app --reload
go to localhost server and view the endpoints
