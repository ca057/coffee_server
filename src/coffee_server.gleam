import app/internal/image_transform_actor
import app/web
import gleam/option
import gleam/otp/static_supervisor as supervisor
import pog

import app/core/environment
import gleam/erlang/process
import gleam/int
import gleam/io
import gleam/result
import mist
import wisp
import wisp/wisp_mist

import app/router

fn start_application_supervisor(db_pool_name: process.Name(pog.Message)) {
  let db_pool_child =
    pog.default_config(db_pool_name)
    |> pog.host("localhost")
    |> pog.port(5432)
    |> pog.user("api")
    |> pog.password(option.Some("local"))
    |> pog.database("nofilter")
    |> pog.pool_size(15)
    |> pog.supervised

  supervisor.new(supervisor.RestForOne)
  |> supervisor.add(db_pool_child)
  // add other
  |> supervisor.start
}

pub fn main() -> Nil {
  io.println("starting the coffee_server")
  wisp.configure_logger()
  let secret_key_base = wisp.random_string(64)
  let db_process_name = process.new_name("db")

  let db_connection = pog.named_connection(db_process_name)

  let assert Ok(_) = start_application_supervisor(db_process_name)
  // TODO: move into supervisor
  let assert Ok(image_processor_subject) =
    image_transform_actor.start(db_connection)

  let assert Ok(_) =
    wisp_mist.handler(
      router.handle_request(web.Context(db_connection, image_processor_subject)),
      secret_key_base,
    )
    |> mist.new
    |> mist.bind(environment.get(environment.Interface))
    |> mist.port(
      int.parse(environment.get(environment.Port)) |> result.unwrap(8080),
    )
    |> mist.start

  process.sleep_forever()
}
