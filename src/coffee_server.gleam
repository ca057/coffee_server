import app/image_transform_actor

import app/core/environment
import gleam/erlang/process
import gleam/int
import gleam/io
import gleam/otp/actor
import gleam/result
import mist
import wisp
import wisp/wisp_mist

import app/router

pub fn main() -> Nil {
  io.println("starting the coffee_server")
  wisp.configure_logger()

  let assert Ok(image_processor) =
    actor.start(actor.on_message(
      actor.new([]),
      image_transform_actor.process_image,
    ))

  let secret_key_base = wisp.random_string(64)

  let assert Ok(_) =
    wisp_mist.handler(
      router.handle_request(image_processor.data),
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
