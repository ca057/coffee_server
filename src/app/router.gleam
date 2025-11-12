import app/web
import gleam/json
import wisp.{type Request, type Response}

import app/features/image/handler as image_handler

pub fn handle_request(req: Request) -> Response {
  use req <- web.middleware(req)

  case wisp.path_segments(req) {
    ["image"] -> image_handler.handle_request(req)
    _ ->
      wisp.json_response(
        web.build_error_response_body(req.path <> " not found")
          |> json.to_string,
        404,
      )
  }
}
