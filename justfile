_default:
  @just --list

[parallel]
dev: dev-db-migrate dev-run dev-squirrel

dev-db:
  #!/usr/bin/env fish
  if test -z (docker ps -aq -f name=coffee-server-db)
    docker run -d --name coffee-server-db -e POSTGRES_PASSWORD=local -e POSTGRES_USER=api -e POSTGRES_DB=nofilter -p 5432:5432 postgres:15
  else
    docker start $(docker ps -aq -f name=coffee-server-db)
  end

dev-db-migrate: dev-db
  just dev-dbmate --wait up

dev-squirrel:
  gleam run -m squirrel

dev-dbmate *ARGUMENTS:
  docker run --rm -it --network=host -v "$(pwd)/db:/db" ghcr.io/amacneil/dbmate --url "postgres://api:local@127.0.0.1:5432/nofilter?sslmode=disable" {{ARGUMENTS}}

dev-run:
  watchexec -rw src API_KEY=local INTERFACE=0.0.0.0 gleam run
