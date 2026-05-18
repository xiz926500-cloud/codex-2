from app.database import metadata
from app.models import ProjectEvent


def test_project_event_table_is_registered() -> None:
    table = metadata.tables["project_events"]

    assert ProjectEvent.__tablename__ == "project_events"
    assert table.c.name.type.length == 120
    assert table.c.status.type.length == 40
