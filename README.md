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
  - [Manually Configure Environment Variables](#manually-configure-environment-variables) 
- [VS Code Dev Container Creation](#vs-code-dev-container-creation) 
- [Build and Launch Stack](#build-and-launch-stack)
- [Makefile](#makefile)
  - [Available Commands](#available-commands)
- [Examples](#examples) 
  - [Example PostGIS Connection](#example-postgis-connection) - [SQLAlchemy](#sqlalchemy) 
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
git clone https://github.com/michaeljamesbancroft/gis-dev-stack.git
cd gis-dev-stack
```

### Set Your PostGIS, pgAdmin, and Jupyter Credentials through Make

The credential files .env and .pgpass can be generated through an interactive prompt with the ```make setup``` command. See the [Makefile](#Makefile) section for further information.

### Manually Configure Environment Variables

Optionally, if you would prefer creating the files yourself:

Create:

```text
.env
```

Example:

```env
POSTGRES_USER=your-username
POSTGRES_PASSWORD=your-password
POSTGRES_DB=gis

PGADMIN_DEFAULT_EMAIL=your-username@example.com
PGADMIN_DEFAULT_PASSWORD=your-password
```

Create:
```text
root/.devcontainer/pgadmin/.pgpass
```

Example:
```
hostname:port:database:username:password
```
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

From the `.devcontainer` directory:

```bash
cd .devcontainer

docker compose --env-file ../.env up -d --build
```
[Return to Table of Contents](#table-of-contents)
## Makefile

This repository includes a Makefile to simplify common Docker workflows, environment setup, debugging, and database access.

### Available Commands

| Command              | Purpose                                                                |
| -------------------- | ---------------------------------------------------------------------- |
| `make setup`         | Generate `.env` and `.pgpass` through an interactive credential prompt |
| `make up`            | Build and start the full stack                                         |
| `make down`          | Stop all services                                                      |
| `make rebuild`       | Force clean Docker rebuild without cache                               |
| `make reset`         | Remove containers and persistent Docker volumes                        |
| `make logs`          | View live container logs                                               |
| `make ps`            | Show Docker Compose service status                                     |
| `make clean`         | Aggressive cleanup including Docker prune                              |
| `make shell-jupyter` | Open a shell inside the Jupyter container                              |
| `make shell-postgis` | Open a shell inside the PostGIS container                              |
| `make psql`          | Launch PostgreSQL CLI inside PostGIS                                   |
| `make status`        | Show running Docker containers                                         |
| `make verify-ports`  | Verify localhost-only port exposure                                    |
| `make init-db`       | Manually re-run database initialization SQL                            |

### Examples

#### Generate credentials and setup environment

```bash
make setup
```

Creates:

```text
.env
.devcontainer/pgadmin/.pgpass
```

through an interactive prompt for:

- PostGIS username/password/database
- pgAdmin email/password
- Jupyter token/password
- pg_tileserv credentials
- notebook database credentials

---

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

#### Stop stack

```bash
make down
```

---

#### Force clean rebuild

```bash
make rebuild
```

Performs:

- no-cache Docker rebuild
- container restart

---

#### Remove containers and persistent volumes

```bash
make reset
```

Useful when:

- changing `POSTGRES_DB`
- re-running initialization SQL
- resetting the development environment

---

#### View logs

```bash
make logs
```

Tail logs from all services.

---

#### View service status

```bash
make ps
```

Shows Docker Compose service state.

---

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

#### Open shell inside Jupyter container

```bash
make shell-jupyter
```

---

#### Open shell inside PostGIS container

```bash
make shell-postgis
```

---

#### Launch PostgreSQL CLI

```bash
make psql
```

Connects directly to the configured PostGIS database.

---

#### Manually re-run schema initialization

```bash
make init-db
```

Useful for testing schema updates without recreating the full environment.

---

#### Aggressive cleanup

```bash
make clean
```

Performs:

- `docker compose down -v`
- Docker system prune

Useful for reclaiming disk space or recovering from corrupted builds.

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

* Apache Sedona integration
* pg_tileserv: DONE
* GeoServer
* Airflow / Prefect orchestration
* Vector tile workflows
* Cloud-native storage support

---

[Return to Table of Contents](#table-of-contents)
## License

MIT License
