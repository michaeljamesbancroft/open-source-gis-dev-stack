import geopandas as gpd
import rasterio
import duckdb
import psycopg2
from sqlalchemy import create_engine

engine = create_engine("postgresql://user:password@postgis:5432/gis")

print("GeoPandas:", gpd.__version__)
print("Rasterio:", rasterio.__version__)
print("DuckDB:", duckdb.__version__)