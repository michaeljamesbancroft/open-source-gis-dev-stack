-- ============================================================
-- 99_dev_helpers.sql
-- Development helper views/functions for GIS Dev Stack
-- ============================================================

---------------------------------------------------------------
-- Helper: list all user tables and views
---------------------------------------------------------------

DROP VIEW IF EXISTS admin.v_database_objects CASCADE;

CREATE VIEW admin.v_database_objects AS
SELECT
    table_schema,
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema NOT IN (
    'pg_catalog',
    'information_schema'
)
ORDER BY
    table_schema,
    table_name;

---------------------------------------------------------------
-- Helper: list geometry columns
---------------------------------------------------------------

DROP VIEW IF EXISTS admin.v_geometry_columns CASCADE;

CREATE VIEW admin.v_geometry_columns AS
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

---------------------------------------------------------------
-- Helper: table row counts
---------------------------------------------------------------

CREATE OR REPLACE FUNCTION admin.row_count(
    schema_name text,
    table_name text
)
RETURNS bigint
LANGUAGE plpgsql
AS
$$
DECLARE
    result bigint;
BEGIN
    EXECUTE format(
        'SELECT COUNT(*) FROM %I.%I',
        schema_name,
        table_name
    )
    INTO result;

    RETURN result;
END;
$$;

---------------------------------------------------------------
-- Helper: summarize geometry validity
---------------------------------------------------------------

CREATE OR REPLACE FUNCTION admin.geometry_validity_summary(
    schema_name text,
    table_name text,
    geom_column text DEFAULT 'geom'
)
RETURNS TABLE (
    total_features bigint,
    valid_features bigint,
    invalid_features bigint,
    null_geometries bigint
)
LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY EXECUTE format(
        '
        SELECT
            COUNT(*)::bigint AS total_features,
            COUNT(*) FILTER (
                WHERE %I IS NOT NULL AND ST_IsValid(%I)
            )::bigint AS valid_features,
            COUNT(*) FILTER (
                WHERE %I IS NOT NULL AND NOT ST_IsValid(%I)
            )::bigint AS invalid_features,
            COUNT(*) FILTER (
                WHERE %I IS NULL
            )::bigint AS null_geometries
        FROM %I.%I
        ',
        geom_column,
        geom_column,
        geom_column,
        geom_column,
        geom_column,
        schema_name,
        table_name
    );
END;
$$;

---------------------------------------------------------------
-- Helper: reset scratch schema
---------------------------------------------------------------

CREATE OR REPLACE FUNCTION admin.reset_scratch_schema()
RETURNS void
LANGUAGE plpgsql
AS
$$
BEGIN
    DROP SCHEMA IF EXISTS scratch CASCADE;
    CREATE SCHEMA scratch;
    COMMENT ON SCHEMA scratch IS
    'Temporary workspace for disposable experiments and notebook outputs.';
END;
$$;

---------------------------------------------------------------
-- Helper: create spatial index if missing
---------------------------------------------------------------

CREATE OR REPLACE FUNCTION admin.create_gist_index_if_missing(
    schema_name text,
    table_name text,
    geom_column text DEFAULT 'geom'
)
RETURNS text
LANGUAGE plpgsql
AS
$$
DECLARE
    index_name text;
    index_exists boolean;
BEGIN
    index_name := format(
        '%s_%s_%s_gix',
        schema_name,
        table_name,
        geom_column
    );

    SELECT EXISTS (
        SELECT 1
        FROM pg_indexes
        WHERE schemaname = schema_name
          AND tablename = table_name
          AND indexname = index_name
    )
    INTO index_exists;

    IF index_exists THEN
        RETURN format('Index already exists: %s', index_name);
    END IF;

    EXECUTE format(
        'CREATE INDEX %I ON %I.%I USING GIST (%I)',
        index_name,
        schema_name,
        table_name,
        geom_column
    );

    RETURN format('Created index: %s', index_name);
END;
$$;

---------------------------------------------------------------
-- Helper: quick environment check
---------------------------------------------------------------

DROP VIEW IF EXISTS admin.v_environment_check CASCADE;

CREATE VIEW admin.v_environment_check AS
SELECT
    version() AS postgres_version,
    postgis_full_version() AS postgis_version,
    current_database() AS database_name,
    current_user AS active_user,
    now() AS checked_at;

---------------------------------------------------------------
-- Helper: sample queries
---------------------------------------------------------------

/*

-- List schemas:
SELECT schema_name
FROM information_schema.schemata
ORDER BY schema_name;

-- List spatial layers:
SELECT *
FROM admin.v_geometry_columns;

-- Check object inventory:
SELECT *
FROM admin.v_database_objects;

-- Count rows:
SELECT admin.row_count('raw', 'parks');

-- Geometry validity:
SELECT *
FROM admin.geometry_validity_summary('staging', 'neighborhoods_clean');

-- Reset scratch schema:
SELECT admin.reset_scratch_schema();

-- Create missing spatial index:
SELECT admin.create_gist_index_if_missing(
    'staging',
    'parks_clean',
    'geom'
);

-- Environment check:
SELECT *
FROM admin.v_environment_check;

*/