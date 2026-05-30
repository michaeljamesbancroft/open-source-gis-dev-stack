import duckdb

def get_spatial_connection(db_path=":memory:"):
    con = duckdb.connect(db_path)
    con.sql("INSTALL spatial;")
    con.sql("LOAD spatial;")
    return con