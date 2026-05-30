-- ============================================================
-- 02_schemas.sql
-- Schema organization + security-oriented permissions
-- ============================================================

---------------------------------------------------------------
-- Create Schemas
---------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS analytics;
CREATE SCHEMA IF NOT EXISTS scratch;
CREATE SCHEMA IF NOT EXISTS tiles;
CREATE SCHEMA IF NOT EXISTS reference;
CREATE SCHEMA IF NOT EXISTS admin;

---------------------------------------------------------------
-- Schema Documentation
---------------------------------------------------------------

COMMENT ON SCHEMA raw IS
'Original imported source datasets. Minimal modification.';

COMMENT ON SCHEMA staging IS
'Cleaned, transformed, normalized intermediate datasets.';

COMMENT ON SCHEMA analytics IS
'Analytical outputs, metrics, models, final analysis products.';

COMMENT ON SCHEMA scratch IS
'Temporary workspace for experimentation and notebook work.';

COMMENT ON SCHEMA tiles IS
'Views/tables intended for pg_tileserv publication.';

COMMENT ON SCHEMA reference IS
'Lookup tables, boundaries, CRS tables, controlled vocabularies.';

COMMENT ON SCHEMA admin IS
'ETL metadata, audit tables, pipeline logs, maintenance objects.';

---------------------------------------------------------------
-- Public Schema Hardening
---------------------------------------------------------------

REVOKE CREATE ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON DATABASE gis FROM PUBLIC;

---------------------------------------------------------------
-- Development User Permissions
-- CURRENT_USER is the user created by POSTGRES_USER.
---------------------------------------------------------------

GRANT CONNECT ON DATABASE gis TO CURRENT_USER;

GRANT USAGE, CREATE ON SCHEMA raw TO CURRENT_USER;
GRANT USAGE, CREATE ON SCHEMA staging TO CURRENT_USER;
GRANT USAGE, CREATE ON SCHEMA analytics TO CURRENT_USER;
GRANT USAGE, CREATE ON SCHEMA scratch TO CURRENT_USER;
GRANT USAGE, CREATE ON SCHEMA tiles TO CURRENT_USER;
GRANT USAGE, CREATE ON SCHEMA reference TO CURRENT_USER;
GRANT USAGE, CREATE ON SCHEMA admin TO CURRENT_USER;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA raw TO CURRENT_USER;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA staging TO CURRENT_USER;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA analytics TO CURRENT_USER;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA scratch TO CURRENT_USER;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA tiles TO CURRENT_USER;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA reference TO CURRENT_USER;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA admin TO CURRENT_USER;

ALTER DEFAULT PRIVILEGES IN SCHEMA raw
GRANT ALL ON TABLES TO CURRENT_USER;

ALTER DEFAULT PRIVILEGES IN SCHEMA staging
GRANT ALL ON TABLES TO CURRENT_USER;

ALTER DEFAULT PRIVILEGES IN SCHEMA analytics
GRANT ALL ON TABLES TO CURRENT_USER;

ALTER DEFAULT PRIVILEGES IN SCHEMA scratch
GRANT ALL ON TABLES TO CURRENT_USER;

ALTER DEFAULT PRIVILEGES IN SCHEMA tiles
GRANT ALL ON TABLES TO CURRENT_USER;

ALTER DEFAULT PRIVILEGES IN SCHEMA reference
GRANT ALL ON TABLES TO CURRENT_USER;

ALTER DEFAULT PRIVILEGES IN SCHEMA admin
GRANT ALL ON TABLES TO CURRENT_USER;

---------------------------------------------------------------
-- Read-Only pg_tileserv Role
---------------------------------------------------------------

DO
$$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_catalog.pg_roles
        WHERE rolname = 'tileserver'
    ) THEN
        CREATE ROLE tileserver
        LOGIN
        PASSWORD 'tileserver_password';
    END IF;
END
$$;

GRANT CONNECT ON DATABASE gis TO tileserver;
GRANT USAGE ON SCHEMA tiles TO tileserver;
GRANT SELECT ON ALL TABLES IN SCHEMA tiles TO tileserver;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA tiles TO tileserver;

ALTER DEFAULT PRIVILEGES IN SCHEMA tiles
GRANT SELECT ON TABLES TO tileserver;

ALTER DEFAULT PRIVILEGES IN SCHEMA tiles
GRANT SELECT ON SEQUENCES TO tileserver;

---------------------------------------------------------------
-- Notebook Role
-- Intended for analysis notebooks with limited permissions.
---------------------------------------------------------------

DO
$$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_catalog.pg_roles
        WHERE rolname = 'notebook'
    ) THEN
        CREATE ROLE notebook
        LOGIN
        PASSWORD 'notebook_password';
    END IF;
END
$$;

GRANT CONNECT ON DATABASE gis TO notebook;

GRANT USAGE ON SCHEMA raw TO notebook;
GRANT USAGE ON SCHEMA staging TO notebook;
GRANT USAGE ON SCHEMA analytics TO notebook;
GRANT USAGE ON SCHEMA scratch TO notebook;
GRANT USAGE ON SCHEMA reference TO notebook;

GRANT SELECT ON ALL TABLES IN SCHEMA raw TO notebook;
GRANT SELECT ON ALL TABLES IN SCHEMA staging TO notebook;
GRANT SELECT ON ALL TABLES IN SCHEMA analytics TO notebook;
GRANT SELECT ON ALL TABLES IN SCHEMA reference TO notebook;

GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA scratch
TO notebook;

GRANT CREATE ON SCHEMA scratch TO notebook;

ALTER DEFAULT PRIVILEGES IN SCHEMA raw
GRANT SELECT ON TABLES TO notebook;

ALTER DEFAULT PRIVILEGES IN SCHEMA staging
GRANT SELECT ON TABLES TO notebook;

ALTER DEFAULT PRIVILEGES IN SCHEMA analytics
GRANT SELECT ON TABLES TO notebook;

ALTER DEFAULT PRIVILEGES IN SCHEMA reference
GRANT SELECT ON TABLES TO notebook;

ALTER DEFAULT PRIVILEGES IN SCHEMA scratch
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO notebook;

---------------------------------------------------------------
-- Verification Comments
---------------------------------------------------------------

/*

SELECT schema_name
FROM information_schema.schemata
WHERE schema_name IN (
    'raw',
    'staging',
    'analytics',
    'scratch',
    'tiles',
    'reference',
    'admin'
)
ORDER BY schema_name;

SELECT rolname
FROM pg_roles
WHERE rolname IN (
    'tileserver',
    'notebook'
)
ORDER BY rolname;

*/