import app/web
import wisp.{type Request, type Response}

import app/handlers/image as image_handler

pub fn handle_request(req: Request) -> Response {
  use req <- web.middleware(req)

  case wisp.path_segments(req) {
    ["images"] -> image_handler.handle_request(req)
    _ -> web.respond_with_error(req.path <> " not found", 404)
  }
}
