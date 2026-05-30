from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[1]

ENV_PATH = ROOT / ".env"
PGPASS_PATH = ROOT / ".devcontainer" / "pgadmin" / ".pgpass"
SERVERS_JSON_PATH = ROOT / ".devcontainer" / "pgadmin" / "servers.json"


def prompt_default(prompt: str, default: str) -> str:
    value = input(f"{prompt} [{default}]: ").strip()
    return value or default


def prompt_required(prompt: str) -> str:
    value = input(prompt).strip()

    if not value:
        raise ValueError(f"{prompt} cannot be blank.")

    return value


def prompt_password(prompt: str, allow_blank: bool = False) -> str:
    value = input(prompt).strip()

    if not allow_blank and not value:
        raise ValueError(f"{prompt} cannot be blank.")

    return value


def validate_identifier(value: str, label: str) -> str:
    if not re.match(r"^[A-Za-z_][A-Za-z0-9_]*$", value):
        raise ValueError(
            f"{label} must begin with a letter or underscore "
            "and contain only letters, numbers, and underscores."
        )

    return value


def load_servers_json() -> dict:
    if SERVERS_JSON_PATH.exists():
        return json.loads(SERVERS_JSON_PATH.read_text(encoding="utf-8"))

    return {"Servers": {}}


def save_servers_json(data: dict) -> None:
    SERVERS_JSON_PATH.parent.mkdir(parents=True, exist_ok=True)
    SERVERS_JSON_PATH.write_text(
        json.dumps(data, indent=2),
        encoding="utf-8"
    )


def get_or_create_pgadmin_server(
    server_name: str,
    postgres_db: str,
    postgres_user: str,
) -> None:
    data = load_servers_json()

    servers = data.setdefault("Servers", {})

    existing_key = None

    for key, server in servers.items():
        if server.get("Name") == server_name:
            existing_key = key
            break

    if existing_key is None:
        numeric_keys = [
            int(key)
            for key in servers.keys()
            if str(key).isdigit()
        ]

        new_key = str(max(numeric_keys, default=0) + 1)

        servers[new_key] = {
            "Name": server_name,
            "Group": "Servers",
            "Host": "postgis",
            "Port": 5432,
            "MaintenanceDB": postgres_db,
            "Username": postgres_user,
            "SSLMode": "prefer",
            "PassFile": "/pgpass"
        }

        print(f"\nCreated new pgAdmin server entry: {server_name}")

    else:
        servers[existing_key].update(
            {
                "Name": server_name,
                "Group": "Servers",
                "Host": "postgis",
                "Port": 5432,
                "MaintenanceDB": postgres_db,
                "Username": postgres_user,
                "SSLMode": "prefer",
                "PassFile": "/pgpass"
            }
        )

        print(f"\nUpdated existing pgAdmin server entry: {server_name}")

    save_servers_json(data)


print("\nGIS Dev Stack Credential Setup")
print("--------------------------------")

# ---------------------------------------------------------
# pgAdmin server registration name
# ---------------------------------------------------------

pgadmin_server_name = prompt_required(
    "pgAdmin server display name: "
)

# ---------------------------------------------------------
# PostGIS credentials
# ---------------------------------------------------------

postgres_user = validate_identifier(
    prompt_default(
        "PostGIS username",
        "gis"
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
print("1. Use default database: gis")
print("2. Enter custom database name")
print("3. Use project-specific database name")

db_choice = prompt_default(
    "Select option",
    "1"
)

if db_choice == "1":

    postgres_db = "gis"

elif db_choice == "2":

    postgres_db = validate_identifier(
        prompt_default(
            "Database name",
            "gis"
        ),
        "Database name"
    )

elif db_choice == "3":

    postgres_db = validate_identifier(
        prompt_default(
            "Project database name",
            "gis_project"
        ),
        "Project database name"
    )

else:
    raise ValueError(
        "Invalid database selection."
    )

print(f"\nSelected database: {postgres_db}")

print(
    "\nNOTE:"
    "\nPOSTGRES_DB is only created during FIRST database initialization."
    "\nIf using an existing Docker volume and changing DB names,"
    "\nrun:"
    "\nmake reset"
)

# ---------------------------------------------------------
# pgAdmin login credentials
# ---------------------------------------------------------

pgadmin_email = prompt_default(
    "pgAdmin email",
    "admin@example.com"
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

# ---------------------------------------------------------
# Generate .pgpass
# ---------------------------------------------------------

pgpass_content = (
    f"postgis:5432:"
    f"{postgres_db}:"
    f"{postgres_user}:"
    f"{postgres_password}\n"
)

ENV_PATH.write_text(
    env_content,
    encoding="utf-8"
)

PGPASS_PATH.parent.mkdir(
    parents=True,
    exist_ok=True
)

PGPASS_PATH.write_text(
    pgpass_content,
    encoding="utf-8"
)

# ---------------------------------------------------------
# Update servers.json
# ---------------------------------------------------------

get_or_create_pgadmin_server(
    server_name=pgadmin_server_name,
    postgres_db=postgres_db,
    postgres_user=postgres_user,
)

# ---------------------------------------------------------
# Completion
# ---------------------------------------------------------

print("\nCreated/updated:")

print(f"  {ENV_PATH}")
print(f"  {PGPASS_PATH}")
print(f"  {SERVERS_JSON_PATH}")

print("\nNext steps:")

print("\ncd .devcontainer")

print(
    "docker compose "
    "--env-file ../.env "
    "up -d --build"
)