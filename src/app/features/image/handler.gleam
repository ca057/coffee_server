import gleam/http
import wisp.{type Request, type Response}

pub fn handle_request(req: Request) -> Response {
  wisp.json_response(
    http.method_to_string(req.method) <> ": not implemented",
    501,
  )
}
