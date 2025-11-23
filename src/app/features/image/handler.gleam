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

  web.respond_with_error(
    http.method_to_string(req.method) <> ": not implemented",
    501,
  )
}
