[parallel]
dev: dev-db dev-run

dev-db:
  docker run -d --name coffee-server-db -e POSTGRES_PASSWORD=postgres -p 5432:5432 postgres:15

dev-dbmate *ARGUMENTS:
  docker run --rm -it --network=host -v "$(pwd)/db:/db" ghcr.io/amacneil/dbmate --url "postgres://postgres:postgres@127.0.0.1:5432/postgres?sslmode=disable" {{ARGUMENTS}}

dev-run:
  watchexec -rw src API_KEY=local INTERFACE=0.0.0.0 gleam run
