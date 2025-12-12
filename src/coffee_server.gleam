import app/internal/image_transform_actor

import app/core/environment
import gleam/erlang/process
import gleam/int
import gleam/io
import gleam/result
import mist
import wisp
import wisp/wisp_mist

import app/router

pub fn main() -> Nil {
  io.println("starting the coffee_server")
  wisp.configure_logger()

  let assert Ok(image_processor_subject) = image_transform_actor.start()

  let secret_key_base = wisp.random_string(64)

  let assert Ok(_) =
    wisp_mist.handler(
      router.handle_request(image_processor_subject),
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
