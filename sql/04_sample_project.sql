-- ============================================================
-- 04_sample_project.sql
-- Simple sample project: park access analysis
-- ============================================================

---------------------------------------------------------------
-- Raw sample data
---------------------------------------------------------------

DROP TABLE IF EXISTS raw.parks CASCADE;
DROP TABLE IF EXISTS raw.neighborhoods CASCADE;

CREATE TABLE raw.parks (
    park_id serial PRIMARY KEY,
    park_name text NOT NULL,
    park_type text,
    geom geometry(Point, 4326) NOT NULL
);

CREATE TABLE raw.neighborhoods (
    neighborhood_id serial PRIMARY KEY,
    neighborhood_name text NOT NULL,
    population integer,
    geom geometry(Polygon, 4326) NOT NULL
);

INSERT INTO raw.parks
    (park_name, park_type, geom)
VALUES
    (
        'Central Park',
        'Community Park',
        ST_SetSRID(ST_Point(-119.8000, 36.7500), 4326)
    ),
    (
        'River Park',
        'Regional Park',
        ST_SetSRID(ST_Point(-119.7800, 36.7650), 4326)
    ),
    (
        'South Park',
        'Neighborhood Park',
        ST_SetSRID(ST_Point(-119.8150, 36.7200), 4326)
    ),
    (
        'East Greenway',
        'Linear Park',
        ST_SetSRID(ST_Point(-119.7000, 36.7350), 4326)
    );

INSERT INTO raw.neighborhoods
    (neighborhood_name, population, geom)
VALUES
    (
        'Northside',
        12500,
        ST_SetSRID(
            ST_GeomFromText(
                'POLYGON((
                    -119.8400 36.7400,
                    -119.7600 36.7400,
                    -119.7600 36.7900,
                    -119.8400 36.7900,
                    -119.8400 36.7400
                ))'
            ),
            4326
        )
    ),
    (
        'Southside',
        15800,
        ST_SetSRID(
            ST_GeomFromText(
                'POLYGON((
                    -119.8500 36.6900,
                    -119.7600 36.6900,
                    -119.7600 36.7400,
                    -119.8500 36.7400,
                    -119.8500 36.6900
                ))'
            ),
            4326
        )
    ),
    (
        'Eastside',
        9800,
        ST_SetSRID(
            ST_GeomFromText(
                'POLYGON((
                    -119.7600 36.7000,
                    -119.6600 36.7000,
                    -119.6600 36.7800,
                    -119.7600 36.7800,
                    -119.7600 36.7000
                ))'
            ),
            4326
        )
    );

CREATE INDEX parks_geom_idx
ON raw.parks
USING GIST (geom);

CREATE INDEX neighborhoods_geom_idx
ON raw.neighborhoods
USING GIST (geom);

---------------------------------------------------------------
-- Staging: cleaned / projected features
---------------------------------------------------------------

DROP TABLE IF EXISTS staging.parks_clean CASCADE;
DROP TABLE IF EXISTS staging.neighborhoods_clean CASCADE;

CREATE TABLE staging.parks_clean AS
SELECT
    park_id,
    park_name,
    park_type,
    ST_MakeValid(geom)::geometry(Point, 4326) AS geom
FROM raw.parks
WHERE geom IS NOT NULL;

CREATE TABLE staging.neighborhoods_clean AS
SELECT
    neighborhood_id,
    neighborhood_name,
    population,
    ST_MakeValid(geom)::geometry(Polygon, 4326) AS geom
FROM raw.neighborhoods
WHERE geom IS NOT NULL;

ALTER TABLE staging.parks_clean
ADD PRIMARY KEY (park_id);

ALTER TABLE staging.neighborhoods_clean
ADD PRIMARY KEY (neighborhood_id);

CREATE INDEX parks_clean_geom_idx
ON staging.parks_clean
USING GIST (geom);

CREATE INDEX neighborhoods_clean_geom_idx
ON staging.neighborhoods_clean
USING GIST (geom);

---------------------------------------------------------------
-- Analytics: neighborhood park access
---------------------------------------------------------------

DROP VIEW IF EXISTS analytics.neighborhood_park_access CASCADE;

CREATE VIEW analytics.neighborhood_park_access AS
SELECT
    n.neighborhood_id,
    n.neighborhood_name,
    n.population,
    COUNT(p.park_id) AS parks_within_1km,
    ROUND(
        MIN(
            ST_Distance(
                n.geom::geography,
                p.geom::geography
            )
        )::numeric,
        2
    ) AS nearest_park_meters,
    CASE
        WHEN COUNT(p.park_id) >= 1 THEN 'Has park access'
        ELSE 'Limited park access'
    END AS access_status,
    n.geom
FROM staging.neighborhoods_clean n
LEFT JOIN staging.parks_clean p
ON ST_DWithin(
    n.geom::geography,
    p.geom::geography,
    1000
)
GROUP BY
    n.neighborhood_id,
    n.neighborhood_name,
    n.population,
    n.geom;

---------------------------------------------------------------
-- Analytics: park service areas
---------------------------------------------------------------

DROP VIEW IF EXISTS analytics.park_service_areas CASCADE;

CREATE VIEW analytics.park_service_areas AS
SELECT
    park_id,
    park_name,
    park_type,
    ST_Buffer(geom::geography, 1000)::geometry(Polygon, 4326) AS geom
FROM staging.parks_clean;

---------------------------------------------------------------
-- Tiles: expose selected layers through pg_tileserv
---------------------------------------------------------------

DROP VIEW IF EXISTS tiles.neighborhood_park_access CASCADE;
DROP VIEW IF EXISTS tiles.park_service_areas CASCADE;
DROP VIEW IF EXISTS tiles.parks CASCADE;

CREATE VIEW tiles.neighborhood_park_access AS
SELECT
    neighborhood_id,
    neighborhood_name,
    population,
    parks_within_1km,
    nearest_park_meters,
    access_status,
    geom
FROM analytics.neighborhood_park_access;

CREATE VIEW tiles.park_service_areas AS
SELECT
    park_id,
    park_name,
    park_type,
    geom
FROM analytics.park_service_areas;

CREATE VIEW tiles.parks AS
SELECT
    park_id,
    park_name,
    park_type,
    geom
FROM staging.parks_clean;

---------------------------------------------------------------
-- Grant pg_tileserv read access
---------------------------------------------------------------

GRANT SELECT ON ALL TABLES IN SCHEMA tiles TO tileserver;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA tiles TO tileserver;