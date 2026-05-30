from pathlib import Path
from getpass import getpass
import re

ROOT = Path(__file__).resolve().parents[1]
ENV_PATH = ROOT / ".env"
PGPASS_PATH = ROOT / ".devcontainer" / "pgadmin" / ".pgpass"


def prompt_default(prompt: str, default: str) -> str:
    value = input(f"{prompt} [{default}]: ").strip()
    return value or default


def prompt_password(prompt: str, allow_blank: bool = False) -> str:
    value = getpass(prompt).strip()

    if not allow_blank and not value:
        raise ValueError(f"{prompt} cannot be blank.")

    if value.lower() in {"password", "admin", "changeme", "change_me"}:
        raise ValueError("Choose a stronger password.")

    return value


def validate_identifier(value: str, label: str) -> str:
    if not re.match(r"^[A-Za-z_][A-Za-z0-9_]*$", value):
        raise ValueError(
            f"{label} must start with a letter or underscore and contain only "
            "letters, numbers, and underscores."
        )
    return value


print("GIS Dev Stack credential setup")
print("--------------------------------\n")

postgres_user = validate_identifier(
    prompt_default("PostGIS username", "gis"),
    "PostGIS username",
)

postgres_password = prompt_password("PostGIS password: ")

print("\nDatabase setup")
print("1. Use default database: gis")
print("2. Enter a custom database name")
print("3. Create/use a project-specific database name")

db_choice = prompt_default("Select option", "1")

if db_choice == "1":
    postgres_db = "gis"
elif db_choice == "2":
    postgres_db = validate_identifier(
        prompt_default("Database name", "gis"),
        "Database name",
    )
elif db_choice == "3":
    project_name = validate_identifier(
        prompt_default("Project database name", "gis_project"),
        "Project database name",
    )
    postgres_db = project_name
else:
    raise ValueError("Invalid database option.")

print(
    f"\nDatabase selected: {postgres_db}\n"
    "Note: If the PostGIS volume is new/empty, Docker will create this database.\n"
    "If the volume already exists, changing POSTGRES_DB will not create a new DB automatically.\n"
    "Run 'docker compose down -v' if you want a clean database initialization."
)

pgadmin_email = prompt_default("pgAdmin email", "admin@example.com")
pgadmin_password = prompt_password("pgAdmin password: ")

jupyter_token = prompt_password(
    "Jupyter token/password [blank allowed for no token]: ",
    allow_blank=True,
)

tileserver_password = prompt_password("pg_tileserv read-only DB password: ")
notebook_password = prompt_password("Notebook DB role password: ")

env_content = f"""POSTGRES_USER={postgres_user}
POSTGRES_PASSWORD={postgres_password}
POSTGRES_DB={postgres_db}

PGADMIN_DEFAULT_EMAIL={pgadmin_email}
PGADMIN_DEFAULT_PASSWORD={pgadmin_password}

JUPYTER_TOKEN={jupyter_token}

TILESERVER_USER=tileserver
TILESERVER_PASSWORD={tileserver_password}

NOTEBOOK_DB_USER=notebook
NOTEBOOK_DB_PASSWORD={notebook_password}
"""

pgpass_content = f"postgis:5432:{postgres_db}:{postgres_user}:{postgres_password}\n"

ENV_PATH.write_text(env_content, encoding="utf-8")

PGPASS_PATH.parent.mkdir(parents=True, exist_ok=True)
PGPASS_PATH.write_text(pgpass_content, encoding="utf-8")

print("\nCreated:")
print(f"- {ENV_PATH}")
print(f"- {PGPASS_PATH}")

print("\nNext commands:")
print("cd .devcontainer")
print("docker compose --env-file ../.env up -d --build")