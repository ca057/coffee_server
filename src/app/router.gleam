import app/image_transform_actor
import app/web
import gleam/erlang/process
import wisp.{type Request, type Response}

import app/handlers/image as image_handler

pub fn handle_request(
  subject: process.Subject(image_transform_actor.ProcessImageMessage),
) {
  fn(req: Request) -> Response {
    use req <- web.middleware(req)

    case wisp.path_segments(req) {
      ["images"] -> image_handler.handle_request(req, subject)
      _ -> web.respond_with_error(req.path <> " not found", 404)
    }
  }
}
