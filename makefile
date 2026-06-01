setup:
	python scripts/setup_env.py

up:
	cd .devcontainer && docker compose --env-file ../.env up -d --build

down:
	cd .devcontainer && docker compose --env-file ../.env down

rebuild:
	cd .devcontainer && docker compose --env-file ../.env build --no-cache
	cd .devcontainer && docker compose --env-file ../.env up -d

reset:
	cd .devcontainer && docker compose --env-file ../.env down -v

logs:
	cd .devcontainer && docker compose --env-file ../.env logs -f

ps:
	cd .devcontainer && docker compose --env-file ../.env ps

clean:
	cd .devcontainer && docker compose --env-file ../.env down -v
	docker system prune -f

shell-jupyter:
	docker exec -it jupyterlab bash

shell-postgis:
	docker exec -it postgis bash

psql:
	docker exec -it postgis psql \
	-U $$POSTGRES_USER \
	-d $$POSTGRES_DB

status:
	docker ps

verify-ports:
	docker ps --format "table {{.Names}}\t{{.Ports}}"

init-db:
	docker exec -it postgis psql \
	-U $$POSTGRES_USER \
	-d $$POSTGRES_DB \
	-f /docker-entrypoint-initdb.d/02_schemas.sql

gdal-shell:
	docker exec -it jupyterlab ogr2ogr --version