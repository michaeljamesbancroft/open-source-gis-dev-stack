-- ============================================================
-- 02_schemas.sql
-- Local solo-developer schema organization for GIS Dev Stack
--
-- Credentials and service roles are NOT defined here.
-- User-specific roles/passwords should be generated locally by:
--
--   scripts/setup_env.py -> sql/98_generated_roles.sql
--
-- ============================================================

---------------------------------------------------------------
-- Create project schemas
---------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS analytics;
CREATE SCHEMA IF NOT EXISTS scratch;
CREATE SCHEMA IF NOT EXISTS tiles;
CREATE SCHEMA IF NOT EXISTS reference;
CREATE SCHEMA IF NOT EXISTS admin;

---------------------------------------------------------------
-- Schema documentation
---------------------------------------------------------------

COMMENT ON SCHEMA raw IS
'Original imported source datasets with minimal modification.';

COMMENT ON SCHEMA staging IS
'Cleaned, transformed, standardized intermediate ETL layers.';

COMMENT ON SCHEMA analytics IS
'Analytical outputs, reporting layers, derived metrics, and final analysis products.';

COMMENT ON SCHEMA scratch IS
'Temporary local workspace for notebooks, debugging, experiments, and disposable tables.';

COMMENT ON SCHEMA tiles IS
'Curated views and tables intended for local pg_tileserv publication.';

COMMENT ON SCHEMA reference IS
'Lookup tables, metadata, CRS references, study boundaries, and controlled vocabularies.';

COMMENT ON SCHEMA admin IS
'Administrative objects, ETL metadata, logs, helper functions, and inspection views.';

---------------------------------------------------------------
-- Local public schema hardening
---------------------------------------------------------------

-- Prevent arbitrary users from creating objects in public.
-- This is still local/dev-friendly but avoids messy object placement.

REVOKE CREATE ON SCHEMA public FROM PUBLIC;

---------------------------------------------------------------
-- Convenience permissions
---------------------------------------------------------------

-- CURRENT_USER is normally the POSTGRES_USER initialized by Docker.
-- This user remains the primary local administrator/developer.

GRANT USAGE, CREATE ON SCHEMA raw TO CURRENT_USER;
GRANT USAGE, CREATE ON SCHEMA staging TO CURRENT_USER;
GRANT USAGE, CREATE ON SCHEMA analytics TO CURRENT_USER;
GRANT USAGE, CREATE ON SCHEMA scratch TO CURRENT_USER;
GRANT USAGE, CREATE ON SCHEMA tiles TO CURRENT_USER;
GRANT USAGE, CREATE ON SCHEMA reference TO CURRENT_USER;
GRANT USAGE, CREATE ON SCHEMA admin TO CURRENT_USER;

---------------------------------------------------------------
-- Default privileges for objects created by CURRENT_USER
---------------------------------------------------------------

ALTER DEFAULT PRIVILEGES IN SCHEMA raw
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO CURRENT_USER;

ALTER DEFAULT PRIVILEGES IN SCHEMA staging
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO CURRENT_USER;

ALTER DEFAULT PRIVILEGES IN SCHEMA analytics
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO CURRENT_USER;

ALTER DEFAULT PRIVILEGES IN SCHEMA scratch
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO CURRENT_USER;

ALTER DEFAULT PRIVILEGES IN SCHEMA tiles
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO CURRENT_USER;

ALTER DEFAULT PRIVILEGES IN SCHEMA reference
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO CURRENT_USER;

ALTER DEFAULT PRIVILEGES IN SCHEMA admin
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO CURRENT_USER;

---------------------------------------------------------------
-- Scratch helper table
---------------------------------------------------------------

CREATE TABLE IF NOT EXISTS scratch.session_notes (
    id BIGSERIAL PRIMARY KEY,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    notebook_name TEXT,
    note TEXT
);

COMMENT ON TABLE scratch.session_notes IS
'Temporary local notebook/debugging notes. Safe to delete.';

---------------------------------------------------------------
-- Admin metadata tables
---------------------------------------------------------------

CREATE TABLE IF NOT EXISTS admin.etl_runs (
    run_id BIGSERIAL PRIMARY KEY,
    pipeline_name TEXT NOT NULL,
    started_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    status TEXT,
    message TEXT
);

COMMENT ON TABLE admin.etl_runs IS
'Local ETL execution history and development pipeline notes.';

CREATE TABLE IF NOT EXISTS admin.data_sources (
    source_id BIGSERIAL PRIMARY KEY,
    source_name TEXT UNIQUE,
    source_type TEXT,
    source_url TEXT,
    source_description TEXT,
    refresh_frequency TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE admin.data_sources IS
'Local catalog of source GIS datasets, APIs, and downloads.';

---------------------------------------------------------------
-- Geometry inventory view
---------------------------------------------------------------

CREATE OR REPLACE VIEW admin.geometry_inventory AS
SELECT
    f_table_schema AS schema_name,
    f_table_name AS table_name,
    f_geometry_column AS geometry_column,
    coord_dimension,
    srid,
    type AS geometry_type
FROM geometry_columns
ORDER BY
    f_table_schema,
    f_table_name,
    f_geometry_column;

COMMENT ON VIEW admin.geometry_inventory IS
'Convenience inventory of PostGIS geometry columns.';

---------------------------------------------------------------
-- Table size monitoring view
---------------------------------------------------------------

CREATE OR REPLACE VIEW admin.table_sizes AS
SELECT
    schemaname,
    tablename,
    pg_size_pretty(
        pg_total_relation_size(
            quote_ident(schemaname)
            || '.'
            || quote_ident(tablename)
        )
    ) AS total_size
FROM pg_tables
WHERE schemaname NOT IN (
    'pg_catalog',
    'information_schema'
)
ORDER BY
    pg_total_relation_size(
        quote_ident(schemaname)
        || '.'
        || quote_ident(tablename)
    ) DESC;

COMMENT ON VIEW admin.table_sizes IS
'Local storage usage report for user-facing tables.';

---------------------------------------------------------------
-- Scratch cleanup helper
---------------------------------------------------------------

CREATE OR REPLACE FUNCTION admin.reset_scratch_schema()
RETURNS VOID
LANGUAGE plpgsql
AS
$$
DECLARE
    obj RECORD;
BEGIN
    FOR obj IN
        SELECT
            tablename
        FROM pg_tables
        WHERE schemaname = 'scratch'
          AND tablename <> 'session_notes'
    LOOP
        EXECUTE
            'DROP TABLE IF EXISTS scratch.'
            || quote_ident(obj.tablename)
            || ' CASCADE';
    END LOOP;
END;
$$;

COMMENT ON FUNCTION admin.reset_scratch_schema() IS
'Drops disposable scratch tables while preserving scratch.session_notes.';

---------------------------------------------------------------
-- Optional local verification queries
---------------------------------------------------------------

/*

-- List project schemas
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

-- Inspect geometry layers
SELECT *
FROM admin.geometry_inventory;

-- Inspect table sizes
SELECT *
FROM admin.table_sizes;

-- Reset scratch workspace
SELECT admin.reset_scratch_schema();

*/