from pathlib import Path
import json

import requests
import geopandas as gpd
from prefect import flow, task
from sqlalchemy import create_engine, text


DB_URL = "postgresql://USERNAME:PASSWORD@postgis:5432/DATABASE_NAME"

RAW_OUTPUT = Path("/home/jovyan/data/raw/live_feed_example.json")


@task
def fetch_live_geojson() -> dict:
    url = "https://example.com/live-data.geojson"

    response = requests.get(url, timeout=30)
    response.raise_for_status()

    data = response.json()

    RAW_OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    RAW_OUTPUT.write_text(
        json.dumps(data, indent=2),
        encoding="utf-8"
    )

    return data


@task
def load_raw_to_postgis(data: dict) -> None:
    gdf = gpd.GeoDataFrame.from_features(
        data["features"],
        crs="EPSG:4326"
    )

    engine = create_engine(DB_URL)

    gdf.to_postgis(
        "live_feed",
        engine,
        schema="raw",
        if_exists="replace",
        index=False
    )


@task
def refresh_tile_view() -> None:
    engine = create_engine(DB_URL)

    sql = """
    CREATE OR REPLACE VIEW tiles.live_feed AS
    SELECT
        *,
        geom
    FROM raw.live_feed;
    """

    with engine.begin() as conn:
        conn.execute(text(sql))


@flow(name="Refresh Live Geospatial Data")
def refresh_live_data() -> None:
    data = fetch_live_geojson()
    load_raw_to_postgis(data)
    refresh_tile_view()


if __name__ == "__main__":
    refresh_live_data()