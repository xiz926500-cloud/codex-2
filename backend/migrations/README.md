# Database Migrations

Alembic tracks database schema changes for the FastAPI service.

Common commands:

```powershell
cd backend
python -m alembic upgrade head
python -m alembic revision --autogenerate -m "describe change"
```

The migration environment reads `DATABASE_URL` through `app.settings.Settings`.
