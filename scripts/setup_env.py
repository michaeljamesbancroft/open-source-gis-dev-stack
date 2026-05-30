from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[1]

ENV_PATH = ROOT / ".env"

PGADMIN_DIR = ROOT / ".devcontainer" / "pgadmin"

PGPASS_PATH = PGADMIN_DIR / ".pgpass"

SERVERS_JSON_PATH = PGADMIN_DIR / "servers.json"


def prompt_required(prompt: str) -> str:

    value = input(prompt).strip()

    if not value:
        raise ValueError(f"{prompt} cannot be blank.")

    return value


def prompt_password(
    prompt: str,
    allow_blank: bool = False
) -> str:

    value = input(prompt).strip()

    if not allow_blank and not value:
        raise ValueError(f"{prompt} cannot be blank.")

    return value


def validate_identifier(
    value: str,
    label: str
) -> str:

    if not re.match(
        r"^[A-Za-z_][A-Za-z0-9_]*$",
        value
    ):
        raise ValueError(
            f"{label} must begin with a letter or underscore "
            "and contain only letters, numbers, and underscores."
        )

    return value


def create_servers_json(
    server_name: str,
    postgres_db: str,
    postgres_user: str
) -> None:

    server_config = {
        "Servers": {
            "1": {
                "Name": server_name,
                "Group": "Servers",
                "Host": "postgis",
                "Port": 5432,
                "MaintenanceDB": postgres_db,
                "Username": postgres_user,
                "SSLMode": "prefer",
                "PassFile": "/pgpass"
            }
        }
    }

    PGADMIN_DIR.mkdir(
        parents=True,
        exist_ok=True
    )

    SERVERS_JSON_PATH.write_text(
        json.dumps(
            server_config,
            indent=2
        ),
        encoding="utf-8"
    )


print("\nGIS Dev Stack Credential Setup")
print("--------------------------------")

# ---------------------------------------------------------
# pgAdmin server display name
# ---------------------------------------------------------

pgadmin_server_name = prompt_required(
    "pgAdmin server display name: "
)

# ---------------------------------------------------------
# PostGIS credentials
# ---------------------------------------------------------

postgres_user = validate_identifier(
    prompt_required(
        "PostGIS username: "
    ),
    "PostGIS username"
)

postgres_password = prompt_password(
    "PostGIS password: "
)

# ---------------------------------------------------------
# Database selection
# ---------------------------------------------------------

print("\nDatabase Setup")
print("1. Use database named 'gis'")
print("2. Enter custom database name")

db_choice = prompt_required(
    "Select option: "
)

if db_choice == "1":

    postgres_db = "gis"

elif db_choice == "2":

    postgres_db = validate_identifier(
        prompt_required(
            "Database name: "
        ),
        "Database name"
    )

else:

    raise ValueError(
        "Invalid database selection."
    )

print(
    f"\nSelected database: {postgres_db}"
)

print(
    "\nNOTE:"
    "\nPOSTGRES_DB is only created during FIRST initialization."
    "\nIf using an existing Docker volume and changing DB names,"
    "\nrun:"
    "\nmake reset"
)

# ---------------------------------------------------------
# pgAdmin login credentials
# ---------------------------------------------------------

pgadmin_email = prompt_required(
    "pgAdmin email: "
)

pgadmin_password = prompt_password(
    "pgAdmin password: "
)

# ---------------------------------------------------------
# Jupyter credentials
# ---------------------------------------------------------

jupyter_token = prompt_password(
    "Jupyter token/password (blank allowed): ",
    allow_blank=True
)

# ---------------------------------------------------------
# pg_tileserv credentials
# ---------------------------------------------------------

tileserver_password = prompt_password(
    "pg_tileserv DB password: "
)

# ---------------------------------------------------------
# notebook role credentials
# ---------------------------------------------------------

notebook_password = prompt_password(
    "Notebook DB role password: "
)

# ---------------------------------------------------------
# Generate .env
# ---------------------------------------------------------

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

ENV_PATH.write_text(
    env_content,
    encoding="utf-8"
)

# ---------------------------------------------------------
# Generate .pgpass
# ---------------------------------------------------------

PGADMIN_DIR.mkdir(
    parents=True,
    exist_ok=True
)

pgpass_content = (
    f"postgis:5432:"
    f"{postgres_db}:"
    f"{postgres_user}:"
    f"{postgres_password}\n"
)

PGPASS_PATH.write_text(
    pgpass_content,
    encoding="utf-8"
)

# ---------------------------------------------------------
# Generate servers.json
# ---------------------------------------------------------

create_servers_json(
    server_name=pgadmin_server_name,
    postgres_db=postgres_db,
    postgres_user=postgres_user,
)

# ---------------------------------------------------------
# Completion
# ---------------------------------------------------------

print("\nCreated:")

print(f"  {ENV_PATH}")
print(f"  {PGPASS_PATH}")
print(f"  {SERVERS_JSON_PATH}")

print("\nNext steps:")

print(
    "\ncd .devcontainer"
)

print(
    "docker compose "
    "--env-file ../.env "
    "up -d --build"
)