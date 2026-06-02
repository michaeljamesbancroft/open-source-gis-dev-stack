from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[1]

ENV_PATH = ROOT / ".env"

PGADMIN_DIR = ROOT / ".devcontainer" / "pgadmin"
PGPASS_PATH = PGADMIN_DIR / ".pgpass"
SERVERS_JSON_PATH = PGADMIN_DIR / "servers.json"

SQL_DIR = ROOT / "sql"
GENERATED_ROLES_SQL_PATH = SQL_DIR / "98_generated_roles.sql"


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


def sql_quote_literal(value: str) -> str:
    return "'" + value.replace("'", "''") + "'"


def create_servers_json(
    server_name: str,
    postgres_db: str,
    postgres_user: str,
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
                "PassFile": "/pgpass",
            }
        }
    }

    PGADMIN_DIR.mkdir(parents=True, exist_ok=True)

    SERVERS_JSON_PATH.write_text(
        json.dumps(server_config, indent=2),
        encoding="utf-8",
    )


def create_generated_roles_sql(
    postgres_db: str,
    tileserver_user: str,
    tileserver_password: str,
    notebook_user: str,
    notebook_password: str,
) -> None:
    SQL_DIR.mkdir(parents=True, exist_ok=True)

    sql = f"""-- ============================================================
-- 98_generated_roles.sql
-- Generated locally by scripts/setup_env.py
-- Do not commit this file.
-- ============================================================

DO
$$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_catalog.pg_roles
        WHERE rolname = {sql_quote_literal(tileserver_user)}
    ) THEN
        EXECUTE format(
            'CREATE ROLE %I LOGIN PASSWORD %L',
            {sql_quote_literal(tileserver_user)},
            {sql_quote_literal(tileserver_password)}
        );
    ELSE
        EXECUTE format(
            'ALTER ROLE %I WITH PASSWORD %L',
            {sql_quote_literal(tileserver_user)},
            {sql_quote_literal(tileserver_password)}
        );
    END IF;
END
$$;

DO
$$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_catalog.pg_roles
        WHERE rolname = {sql_quote_literal(notebook_user)}
    ) THEN
        EXECUTE format(
            'CREATE ROLE %I LOGIN PASSWORD %L',
            {sql_quote_literal(notebook_user)},
            {sql_quote_literal(notebook_password)}
        );
    ELSE
        EXECUTE format(
            'ALTER ROLE %I WITH PASSWORD %L',
            {sql_quote_literal(notebook_user)},
            {sql_quote_literal(notebook_password)}
        );
    END IF;
END
$$;

GRANT CONNECT ON DATABASE {postgres_db} TO {tileserver_user};
GRANT CONNECT ON DATABASE {postgres_db} TO {notebook_user};

GRANT USAGE ON SCHEMA tiles TO {tileserver_user};
GRANT SELECT ON ALL TABLES IN SCHEMA tiles TO {tileserver_user};
GRANT SELECT ON ALL SEQUENCES IN SCHEMA tiles TO {tileserver_user};

ALTER DEFAULT PRIVILEGES IN SCHEMA tiles
GRANT SELECT ON TABLES TO {tileserver_user};

ALTER DEFAULT PRIVILEGES IN SCHEMA tiles
GRANT SELECT ON SEQUENCES TO {tileserver_user};

GRANT USAGE ON SCHEMA raw TO {notebook_user};
GRANT USAGE ON SCHEMA staging TO {notebook_user};
GRANT USAGE ON SCHEMA analytics TO {notebook_user};
GRANT USAGE ON SCHEMA scratch TO {notebook_user};
GRANT USAGE ON SCHEMA reference TO {notebook_user};

GRANT SELECT ON ALL TABLES IN SCHEMA raw TO {notebook_user};
GRANT SELECT ON ALL TABLES IN SCHEMA staging TO {notebook_user};
GRANT SELECT ON ALL TABLES IN SCHEMA analytics TO {notebook_user};
GRANT SELECT ON ALL TABLES IN SCHEMA reference TO {notebook_user};

GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA scratch
TO {notebook_user};

GRANT CREATE ON SCHEMA scratch TO {notebook_user};

ALTER DEFAULT PRIVILEGES IN SCHEMA raw
GRANT SELECT ON TABLES TO {notebook_user};

ALTER DEFAULT PRIVILEGES IN SCHEMA staging
GRANT SELECT ON TABLES TO {notebook_user};

ALTER DEFAULT PRIVILEGES IN SCHEMA analytics
GRANT SELECT ON TABLES TO {notebook_user};

ALTER DEFAULT PRIVILEGES IN SCHEMA reference
GRANT SELECT ON TABLES TO {notebook_user};

ALTER DEFAULT PRIVILEGES IN SCHEMA scratch
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO {notebook_user};
"""

    GENERATED_ROLES_SQL_PATH.write_text(sql, encoding="utf-8")


print("\nGIS Dev Stack Credential Setup")
print("--------------------------------")

pgadmin_server_name = prompt_required("pgAdmin server display name: ")

postgres_user = validate_identifier(
    prompt_required("PostGIS admin username: "),
    "PostGIS admin username",
)

postgres_password = prompt_password("PostGIS admin password: ")

print("\nDatabase Setup")
print("1. Use database named 'gis'")
print("2. Enter custom database name")

db_choice = prompt_required("Select option: ")

if db_choice == "1":
    postgres_db = "gis"
elif db_choice == "2":
    postgres_db = validate_identifier(
        prompt_required("Database name: "),
        "Database name",
    )
else:
    raise ValueError("Invalid database selection.")

print(f"\nSelected database: {postgres_db}")

print(
    "\nNOTE:"
    "\nPOSTGRES_DB is only created during first database initialization."
    "\nIf using an existing Docker volume and changing DB names or role passwords,"
    "\nrun:"
    "\nmake reset"
)

pgadmin_email = prompt_required("pgAdmin email: ")
pgadmin_password = prompt_password("pgAdmin password: ")

jupyter_token = prompt_password(
    "Jupyter token/password (blank allowed): ",
    allow_blank=True,
)

tileserver_user = "tileserver"
tileserver_password = prompt_password("pg_tileserv DB password: ")

notebook_user = "notebook"
notebook_password = prompt_password("Notebook DB role password: ")

print("\nMinIO Cloud Storage Setup")

minio_root_user = prompt_required(
    "MinIO admin username: "
)

minio_root_password = prompt_password(
    "MinIO admin password: "
)

minio_bucket = prompt_required(
    "MinIO default bucket name: "
)

env_content = f"""POSTGRES_USER={postgres_user}
POSTGRES_PASSWORD={postgres_password}
POSTGRES_DB={postgres_db}

PGADMIN_DEFAULT_EMAIL={pgadmin_email}
PGADMIN_DEFAULT_PASSWORD={pgadmin_password}

JUPYTER_TOKEN={jupyter_token}

TILESERVER_USER={tileserver_user}
TILESERVER_PASSWORD={tileserver_password}

NOTEBOOK_DB_USER={notebook_user}
NOTEBOOK_DB_PASSWORD={notebook_password}

MINIO_ROOT_USER={minio_root_user}
MINIO_ROOT_PASSWORD={minio_root_password}

S3_ENDPOINT_URL=http://minio:9000
S3_BUCKET={minio_bucket}
"""

ENV_PATH.write_text(env_content, encoding="utf-8")

PGADMIN_DIR.mkdir(parents=True, exist_ok=True)

pgpass_content = (
    f"postgis:5432:"
    f"{postgres_db}:"
    f"{postgres_user}:"
    f"{postgres_password}\n"
)

PGPASS_PATH.write_text(pgpass_content, encoding="utf-8")

create_servers_json(
    server_name=pgadmin_server_name,
    postgres_db=postgres_db,
    postgres_user=postgres_user,
)

create_generated_roles_sql(
    postgres_db=postgres_db,
    tileserver_user=tileserver_user,
    tileserver_password=tileserver_password,
    notebook_user=notebook_user,
    notebook_password=notebook_password,
)

print("\nCreated configuration:")

print(f"  {ENV_PATH}")
print(f"  {PGPASS_PATH}")
print(f"  {SERVERS_JSON_PATH}")
print(f"  {GENERATED_ROLES_SQL_PATH}")

print(
    "\nMinIO Console:"
    "\nhttp://localhost:9001"
)

print(
    "\nMinIO S3 API:"
    "\nhttp://localhost:9000"
)

print("\nNext steps:")
print("\nmake up (Start the Docker containers)")