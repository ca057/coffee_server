import gleam/erlang/process
import wisp
import mist
import wisp/wisp_mist
import gleam/io

import app/router

pub fn main() -> Nil {
  io.println("starting the coffee_server")
  wisp.configure_logger()

  let secret_key_base = wisp.random_string(64)

  let assert Ok(_) = wisp_mist.handler(router.handle_request, secret_key_base)
  |> mist.new
  |> mist.port(7000)
  |> mist.start

  process.sleep_forever()
}
