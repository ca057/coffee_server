import wisp.{type Request, type Response}
import gleam/http
import app/web

pub fn handle_request(req: Request) -> Response {
  use req <- web.middleware(req)

  case req.method, wisp.path_segments(req) {
    http.Get, _ -> wisp.json_response("{ \"path\": \"" <> req.path <> "\"}", 200)
    _, _ -> wisp.not_found()
  }
}
