-- ============================================================
-- 03_reference_data.sql
-- Reference / lookup data for GIS Dev Stack
-- ============================================================

---------------------------------------------------------------
-- Reference: land cover classes
---------------------------------------------------------------

DROP TABLE IF EXISTS reference.landcover_lookup CASCADE;

CREATE TABLE reference.landcover_lookup (
    landcover_code integer PRIMARY KEY,
    landcover_name text NOT NULL,
    landcover_group text NOT NULL
);

INSERT INTO reference.landcover_lookup
    (landcover_code, landcover_name, landcover_group)
VALUES
    (11, 'Open Water', 'Water'),
    (21, 'Developed, Open Space', 'Developed'),
    (22, 'Developed, Low Intensity', 'Developed'),
    (23, 'Developed, Medium Intensity', 'Developed'),
    (24, 'Developed, High Intensity', 'Developed'),
    (31, 'Barren Land', 'Barren'),
    (41, 'Deciduous Forest', 'Forest'),
    (42, 'Evergreen Forest', 'Forest'),
    (43, 'Mixed Forest', 'Forest'),
    (52, 'Shrub/Scrub', 'Shrubland'),
    (71, 'Grassland/Herbaceous', 'Grassland'),
    (81, 'Pasture/Hay', 'Agriculture'),
    (82, 'Cultivated Crops', 'Agriculture'),
    (90, 'Woody Wetlands', 'Wetlands'),
    (95, 'Emergent Herbaceous Wetlands', 'Wetlands');

---------------------------------------------------------------
-- Reference: project CRS catalog
---------------------------------------------------------------

DROP TABLE IF EXISTS reference.project_crs CASCADE;

CREATE TABLE reference.project_crs (
    crs_name text PRIMARY KEY,
    epsg_code integer NOT NULL,
    purpose text
);

INSERT INTO reference.project_crs
    (crs_name, epsg_code, purpose)
VALUES
    ('WGS84', 4326, 'Web, GPS, general geographic coordinates'),
    ('Web Mercator', 3857, 'Web mapping and tile services'),
    ('California Albers', 3310, 'California area and distance analysis'),
    ('NAD83 / California Zone 4 ftUS', 2228, 'Central California local projected analysis');

---------------------------------------------------------------
-- Reference: sample project boundary
---------------------------------------------------------------

DROP TABLE IF EXISTS reference.study_area CASCADE;

CREATE TABLE reference.study_area (
    study_area_id serial PRIMARY KEY,
    study_area_name text NOT NULL,
    geom geometry(Polygon, 4326) NOT NULL
);

INSERT INTO reference.study_area
    (study_area_name, geom)
VALUES
    (
        'Sample Fresno-Clovis Study Area',
        ST_SetSRID(
            ST_GeomFromText(
                'POLYGON((
                    -119.90 36.65,
                    -119.65 36.65,
                    -119.65 36.85,
                    -119.90 36.85,
                    -119.90 36.65
                ))'
            ),
            4326
        )
    );

CREATE INDEX study_area_geom_idx
ON reference.study_area
USING GIST (geom);

---------------------------------------------------------------
-- Reference: metadata table for data sources
---------------------------------------------------------------

DROP TABLE IF EXISTS reference.data_sources CASCADE;

CREATE TABLE reference.data_sources (
    source_id serial PRIMARY KEY,
    source_name text NOT NULL,
    source_url text,
    source_description text,
    source_date date,
    ingested_at timestamp DEFAULT now()
);

INSERT INTO reference.data_sources
    (source_name, source_url, source_description, source_date)
VALUES
    (
        'Synthetic Demo Data',
        NULL,
        'Synthetic sample features created for local PostGIS development and portfolio demonstration.',
        CURRENT_DATE
    );