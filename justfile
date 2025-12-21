dev-db:
  docker run -d --name coffee-server-db -e POSTGRES_PASSWORD=postgres -p 5432:5432 postgres:15

run:
  watchexec -rw src API_KEY=local INTERFACE=0.0.0.0 gleam run
