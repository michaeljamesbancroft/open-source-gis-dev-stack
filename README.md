# Open Source GIS Dev Stack — Dockerized Open Source Geospatial Analytics Environment

A reproducible geospatial analytics development environment using Docker, PostGIS, pgAdmin, JupyterLab, GeoPandas, and modern Python GIS tooling.

This repository provides an isolated development stack for:

* Spatial SQL analytics
* PostGIS database development
* Python geospatial workflows
* GeoPandas / Rasterio analysis
* Jupyter-based experimentation
* Reproducible GIS data engineering environments

---

## Table of Contents 
- [Technology Stack](#technology-stack) 
  - [Core GIS / Vector / Raster](#core-gis--vector--raster) 
  - [Database / Spatial SQL](#database--spatial-sql) 
  - [Spatial Statistics / Spatial Econometrics](#spatial-statistics--spatial-econometrics) 
  - [Network / Accessibility / Transportation GIS](#network--accessibility--transportation-gis) 
  - [Scientific Computing / Machine Learning](#scientific-computing--machine-learning) 
  - [Hydrology / Terrain / Environmental Modeling](#hydrology--terrain--environmental-modeling) 
  - [Interactive Mapping / Visualization](#interactive-mapping--visualization) 
  - [Data Engineering / Formats](#data-engineering--formats) 
  - [LiDAR / 3D GIS](#lidar--3d-gis) 
  - [Geocoding / Utilities](#geocoding--utilities)
  - [Jupyter Development Environment](#jupyter-development-environment) 
- [Infrastructure / Services](#infrastructure--services) 
- [Example Workflow](#example-workflow)
- [Repository Structure](#repository-structure) 
- [Features](#features) 
- [Quick Start](#quick-start) 
  - [Clone Repository](#clone-repository) 
  - [Set Your PostGIS, pgAdmin, and Jupyter Credentials through Make](#set-your-postgis-pgadmin-and-jupyter-credentials-through-make)
- [VS Code Dev Container Creation](#vs-code-dev-container-creation) 
- [Build and Launch Stack](#build-and-launch-stack)
- [Makefile](#makefile)
  - [Available Commands](#available-commands)
- [Examples](#examples) 
  - [Example PostGIS Connection](#example-postgis-connection)
  - [SQLAlchemy](#sqlalchemy) 
  - [GeoPandas](#geopandas) 
- [Included Python Packages](#included-python-packages) 
- [Example Use Cases](#example-use-cases) 
- [Future Enhancements](#future-enhancements) 
- [License](#license)

---
[Return to Table of Contents](#table-of-contents)
## Technology Stack

### Core GIS / Vector / Raster

| Library      | Purpose                                           |
| ------------ | ------------------------------------------------- |
| GeoPandas    | Vector GIS analysis and spatial dataframes        |
| GDAL / osgeo | Core geospatial raster/vector IO and processing   |
| Rasterio     | Raster analysis and processing                    |
| Fiona        | Vector GIS file IO                                |
| Pyogrio      | High-performance geospatial IO                    |
| Shapely      | Geometry operations                               |
| PyProj       | Coordinate systems and CRS transformations        |
| Rtree        | Spatial indexing                                  |
| Xarray       | Multidimensional environmental / raster analytics |
| Rioxarray    | Raster + Xarray integration                       |
| EarthPy      | Environmental and remote sensing workflows        |
| Cartopy      | Cartographic projections and geospatial plotting  |

### Database / Spatial SQL

| Library       | Purpose                           |
| ------------- | --------------------------------- |
| SQLAlchemy    | Database ORM / connection engine  |
| GeoAlchemy2   | Spatial SQLAlchemy support        |
| Psycopg2      | PostgreSQL / PostGIS connectivity |
| DuckDB        | Embedded analytical database      |
| DuckDB Engine | SQLAlchemy integration for DuckDB |

### Spatial Statistics / Spatial Econometrics

| Library  | Purpose                                      |
| -------- | -------------------------------------------- |
| libpysal | Spatial weights and neighborhood analysis    |
| ESDA     | Spatial autocorrelation and hotspot analysis |
| spreg    | Spatial regression modeling                  |
| MGWR     | Geographically Weighted Regression           |

### Network / Accessibility / Transportation GIS

| Library  | Purpose                              |
| -------- | ------------------------------------ |
| NetworkX | Graph and network analysis           |
| OSMnx    | OpenStreetMap network analysis       |
| Pandana  | Accessibility and proximity modeling |

### Scientific Computing / Machine Learning

| Library      | Purpose              |
| ------------ | -------------------- |
| SciPy        | Scientific computing |
| Scikit-learn | Machine learning     |
| Statsmodels  | Statistical modeling |

### Hydrology / Terrain / Environmental Modeling

| Library       | Purpose                                          |
| ------------- | ------------------------------------------------ |
| PySheds       | Watershed and hydrologic modeling                |
| WhiteboxTools | Terrain, DEM, geomorphology, and raster analysis |

### Interactive Mapping / Visualization

| Library      | Purpose                                          |
| ------------ | ------------------------------------------------ |
| Folium       | Leaflet web mapping                              |
| Contextily   | Basemap integration                              |
| MovingPandas | Trajectory and movement analysis                 |
| ipyleaflet   | Interactive notebook mapping                     |
| Kepler.gl    | Large-scale interactive geospatial visualization |
| Bokeh        | Interactive plotting                             |
| Panel        | Dashboard applications                           |
| Streamlit    | GIS and analytics web applications               |

### Data Engineering / Formats

| Library        | Purpose                        |
| -------------- | ------------------------------ |
| PyArrow        | Parquet / Arrow support        |
| Dask-GeoPandas | Parallel geospatial processing |
| Intake         | Data catalog management        |

### LiDAR / 3D GIS

| Library   | Purpose                              |
| --------- | ------------------------------------ |
| LasPy     | LiDAR / LAS point cloud processing   |
| Open3D    | 3D geometry and point cloud analysis |
| PyntCloud | Point cloud analytics                |

### Geocoding / Utilities

| Library | Purpose                                          |
| ------- | ------------------------------------------------ |
| GeoPy   | Geocoding and geodesic calculations              |
| CenPy   | US Census API workflows                          |
| Tkinter | Optional GUI support for compatible Python tools |

### Jupyter Development Environment

| Library           | Purpose                               |
| ----------------- | ------------------------------------- |
| JupyterLab        | Notebook IDE                          |
| ipykernel         | Python kernels                        |
| JupyterLab Git    | Git integration                       |
| JupyterLab LSP    | Language server support               |
| Python LSP Server | Autocomplete, diagnostics, navigation |
| ipywidgets        | Interactive notebook widgets          |
| nbdime            | Notebook diffing                      |
| Black             | Code formatting                       |
| Ruff              | Fast linting                          |

### Infrastructure / Services

| Service              | Purpose                           | URL                   |
| -------------------- | --------------------------------- | --------------------- |
| PostgreSQL + PostGIS | Spatial database                  | localhost:5432        |
| pgAdmin              | Database administration UI        | http://localhost:5050 |
| Adminer              | Lightweight database UI           | http://localhost:8080 |
| JupyterLab           | Interactive analytics environment | http://localhost:8888 |
| pg_tileserv          | PostGIS vector tile server        | http://localhost:7800 |
| MinIO API            | S3-compatible object storage API  | http://localhost:9000 |
| MinIO Console        | Object storage browser UI         | http://localhost:9001 |

Note: All exposed services are bound to `127.0.0.1` by default to ensure the services run locally on your machine rather than through your local network.

### Example Workflow

```text
External GIS Data
        ↓
GeoPandas / GDAL / Rasterio
        ↓
PostGIS Spatial SQL
        ↓
DuckDB / Analytics
        ↓
GeoParquet Outputs
        ↓
pg_tileserv
        ↓
MapLibre / Leaflet / Dashboards
```


---

[Return to Table of Contents](#table-of-contents)
## Repository Structure

```text
gis-dev-stack/
├── .devcontainer/
│   ├── devcontainer.json
│   ├── docker-compose.yml
│   ├── Dockerfile
│   └── pgadmin/
│       ├── servers.json
│       └── .pgpass
├── notebooks/
├── requirements.txt
├── .env
└── README.md
```

---

[Return to Table of Contents](#table-of-contents)
## Features

* Dockerized PostGIS database

* Auto-configured pgAdmin server registration

* Passwordless Jupyter notebook access

* Pinned Python dependency versions

* Persistent database volumes

* VS Code Dev Container support

* Reproducible geospatial analytics environment

---

[Return to Table of Contents](#table-of-contents)
## Quick Start

### Clone Repository

```bash
git clone https://github.com/michaeljamesbancroft/open-source-gis-dev-stack.git
cd open-source-gis-dev-stack
```

### Set Your PostGIS, pgAdmin, and Jupyter Credentials through Make

The credential files .env and .pgpass can be generated through an interactive prompt with the ```make setup``` and subsequent ```make apply-roles``` commands. See the [Makefile](#Makefile) section for further information.

---

### VS Code Dev Container Creation

Open repository in Visual Studio Code.

Run:

```text
Dev Containers: Rebuild and Reopen in Container
```

The development environment will automatically provision:

* PostGIS database
* pgAdmin configuration
* Python GIS environment
* JupyterLab workspace

---

[Return to Table of Contents](#table-of-contents)
### Build and Launch Stack

From the root directory:

```bash
make up
```
[Return to Table of Contents](#table-of-contents)
## Makefile

This repository includes a Makefile to simplify common Docker workflows, environment setup, debugging, and database access.

### Available Commands

| Command              | Purpose                                                                |
| -------------------- | ---------------------------------------------------------------------- |
| [make setup](#generate-credentials-and-setup-environment)       | Generate `.env` and `.pgpass` through an interactive credential prompt     |
| [make apply-roles](#apply-database-roles-to-user)               | Sets database permissions for user and pg_tileserv                         |
| [make up](#build-and-launch-stack)                              | Build and start the full stack                                             |
| [make down](#stop-stack)                                        | Stop all services                                                          |
| [make rebuild](#force-clean-rebuild)                            | Force clean Docker rebuild without cache                                   |
| [make reset](#remove-containers-and-persistent-volumes)         | Remove containers and persistent Docker volumes                            |
| [make logs](#view-logs)                                         | View live container logs                                                   |
| [make ps](#view-service-status)                                 | Show Docker Compose service status                                         |
| [make clean](#aggressive-cleanup)                               | Aggressive cleanup including Docker prune                                  |
| [make shell-jupyter](#open-shell-inside-jupyter-container)      | Open a shell inside the Jupyter container                                  |
| [make shell-postgis](#open-shell-inside-postgis-container)      | Open a shell inside the PostGIS container                                  |
| [make shell-gdal](#gdal-shell-within-jupyter-notebook)          | Open shell inside Jupyter container using GDAL commands (e.g. ogr2ogr)     |
| [make psql](#launch-postgresql-cli)                             | Launch PostgreSQL CLI inside PostGIS                                       |
| [make status](#show-running-docker-containers)                  | Show running Docker containers                                             |
| [make verify-ports](#verify-localhost-only-exposure)            | Verify localhost-only port exposure                                        |
| [make init-db](#manually-re-run-schema-initialization)          | Manually re-run database initialization SQL                                |
| [make refresh-live](#refresh-live-notebook-data-with-prefect)   | Pull latest API data into Jupyter notebook with Prefect                    |
| [make prefect-server](#start-prefect-server-inside-notebook)    | Start a Prefect Version inside your Jupyter notebook                       |
| [make prefect-version](#check-installed-prefect-version)        | Check version of Prefect installed in your containter                      |
| [make minio-console](#print-minio-console)                      | Prints the minio console URL to your terminal                              |
| [make minio-api](#print-minio-api)                              | Prints the URL to the minio API to your terminal                           |
| [make create-bucket](#create-minio-bucket)                      | Creates a minio bucket with the create_minio_bucket.py script              |

### Examples

[Back to Commands](#available-commands)
#### Generate credentials and setup environment

```bash
make setup
```

Creates:

```text
.env
.devcontainer/pgadmin/.pgpass
.devcontainer/pgadmin/servers.json
sql/98_generated_roles.sql
```

through an interactive prompt for:

- PostGIS username/password/database
- pgAdmin email/password
- Jupyter token/password
- pg_tileserv credentials
- notebook database credentials

---

[Back to Commands](#available-commands)
#### Apply Database Roles to User

```bash
make apply-roles
```

Equivalent to:

```bash
cd .devcontainer && docker compose --env-file ../.env exec -T postgis psql -U $(grep POSTGRES_USER ../.env | cut -d= -f2) -d $(grep POSTGRES_DB ../.env | cut -d= -f2) < ../sql/98_generated_roles.sql
```

Sets database permissions for the user and pg_tileserv from sql/98_generated_roles.sql generated by scripts/setup_env.py to avoid hardcoded credential values and login errors.

---

[Back to Commands](#available-commands)
#### Build and start stack

```bash
make up
```

Equivalent to:

```bash
cd .devcontainer
docker compose --env-file ../.env up -d --build
```


---

[Back to Commands](#available-commands)
#### Stop stack

```bash
make down
```

---

[Back to Commands](#available-commands)
#### Force clean rebuild

```bash
make rebuild
```

Performs:

- no-cache Docker rebuild
- container restart

---

[Back to Commands](#available-commands)
#### Remove containers and persistent volumes

```bash
make reset
```

Useful when:

- changing `POSTGRES_DB`
- re-running initialization SQL
- resetting the development environment

---

[Back to Commands](#available-commands)
#### View logs

```bash
make logs
```

Tail logs from all services.

---

[Back to Commands](#available-commands)
#### View service status

```bash
make ps
```

Shows Docker Compose service state.

---

[Back to Commands](#available-commands)
#### Aggressive cleanup

```bash
make clean
```

Performs:

- `docker compose down -v`
- Docker system prune

Useful for reclaiming disk space or recovering from corrupted builds.

---

[Back to Commands](#available-commands)
#### Open shell inside Jupyter container

```bash
make shell-jupyter
```

---

[Back to Commands](#available-commands)
#### Open shell inside PostGIS container

```bash
make shell-postgis
```

---

[Back to Commands](#available-commands)
### GDAL Shell Within Jupyter Notebook

```bash
make shell-gdal
```

Useful for importing data to PostGIS through a Jupyter notebook from command line BASH.

---

[Back to Commands](#available-commands)
#### Launch PostgreSQL CLI

```bash
make psql
```

Connects directly to the configured PostGIS database.

---

[Back to Commands](#available-commands)
### Show running Docker containers

```bash
make status
```

Runs
```text
docker ps
```

Outputs table showing Container ID, Image, Command, Created, Status, and Ports for Docker container

---

[Back to Commands](#available-commands)
#### Verify localhost-only exposure

```bash
make verify-ports
```

Expected output:

```text
NAMES        PORTS
postgis      127.0.0.1:5432->5432/tcp
pgadmin      127.0.0.1:5050->80/tcp
jupyterlab   127.0.0.1:8888->8888/tcp
pg_tileserv  127.0.0.1:7800->7800/tcp
adminer      127.0.0.1:8080->8080/tcp
```

Confirms services are bound to localhost and not exposed to the LAN.

---

[Back to Commands](#available-commands)
#### Manually re-run schema initialization

```bash
make init-db
```

Useful for testing schema updates without recreating the full environment.

---

[Back to Commands](#available-commands)
#### Refresh Live Notebook Data with Prefect

```bash
make refresh-live
```

Executes the local Prefect geospatial live-data refresh workflow.

Output:

```text
downloads live data
writes raw JSON snapshot
loads/updates PostGIS tables
refreshes tiles schema outputs
```

---

[Back to Commands](#available-commands)
####  Start Prefect Server Inside Notebook

```bash
make prefect-server
```

Launches the local Prefect UI and orchestration backend.

Output:

```text
Prefect API server
workflow dashboard
job monitoring UI
```

Accessible at:

```text
http://localhost:4200
```

---

[Back to Commands](#available-commands)
#### Check Installed Prefect Version

```bash
make prefect-version
```

Displays the installed Prefect version inside the Jupyter container.

Example output:

```text
Version: 3.x.x
API version: ...
```

---

[Back to Commands](#available-commands)
#### Print Minio Console

```bash
make minio-console
```

Command
```bash
@echo "MinIO Console: http://localhost:9001"
```

Outputs

```text
http://localhost:9001
```

Prints the URL to the minio console to your terminal for convenience

---

[Back to Commands](#available-commands)
#### Print Minio API

```bash
make minio-api
```

Command
```bash
@echo "MinIO S3 API: http://localhost:9000"
```

Outputs

```text
http://localhost:9000
```

Prints the URL to the minio API to your terminal for convenience

---

[Back to Commands](#available-commands)
#### Create Minio Bucket

```bash
make create-bucket
```

Commands
```bash
docker exec -it jupyterlab \
python scripts/create_minio_bucket.py
```

Example Output (First Run)
```text
docker exec -it jupyterlab python scripts/create_minio_bucket.py

Connecting to MinIO...
Endpoint: http://minio:9000

Authenticated successfully.

Checking bucket: gis-data

Bucket does not exist.

Created bucket: gis-data

Done.
```

---

**Note:** If your shell does not already include `make`, install it using:

- [Chocolatey](https://chocolatey.org/install)
- [Scoop](https://scoop.sh/)
- Git Bash package manager
- your preferred shell package manager

---

[Return to Table of Contents](#table-of-contents)
## Example PostGIS Connection

### SQLAlchemy

```python
from sqlalchemy import create_engine

engine = create_engine(
    "postgresql://user:password@postgis:5432/gis"
)
```

### GeoPandas

```python
import geopandas as gpd

query = """
SELECT
    ST_Buffer(
        ST_Point(-120, 37),
        1
    ) AS geom
"""

gdf = gpd.read_postgis(
    query,
    engine,
    geom_col="geom"
)
```

---

[Return to Table of Contents](#table-of-contents)
## Included Python Packages

Pinned versions are maintained in:

```text
requirements.txt
```

Key packages include:

* geopandas
* rasterio
* shapely
* duckdb
* sqlalchemy
* psycopg2
* geoalchemy2
* dask-geopandas
* contextily
* folium
* prefect

---

[Return to Table of Contents](#table-of-contents)
## Example Use Cases

This environment is suitable for:

* Spatial ETL pipelines
* Environmental GIS analytics
* Geospatial data engineering
* PostGIS development
* Raster and vector analysis
* SQL + Python geospatial workflows
* Portfolio projects and reproducible research

---

[Return to Table of Contents](#table-of-contents)
## Future Enhancements

Planned additions:

~~* pg_tileserv vector tile workflows: DONE~~
~~* Airflow / Prefect orchestration: DONE~~
~~* Cloud-native storage support: DONE (Minio integration)~~
* GeoServer
* Apache Sedona integration

---

[Return to Table of Contents](#table-of-contents)
## License

[MIT License](https://mit-license.org/)
