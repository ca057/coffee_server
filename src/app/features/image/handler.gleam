import app/core/api_key
import app/core/environment
import app/web
import gleam/http
import wisp.{type Request, type Response}

pub fn handle_request(req: Request) -> Response {
  use req, _ <- web.require_api_key_middleware(
    req,
    api_key.new(environment.get(environment.ApiKey)),
  )

  case req.method, wisp.path_segments(req) {
    // TODO: find a better structure
    http.Put, ["images"] -> wisp.json_response("", 200)
    _, _ -> web.respond_with_error("not found", 404)
  }
}
