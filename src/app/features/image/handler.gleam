import app/web
import gleam/http
import gleam/json
import wisp.{type Request, type Response}

pub fn handle_request(req: Request) -> Response {
  wisp.json_response(
    web.build_error_response_body(
      http.method_to_string(req.method) <> ": not implemented",
    )
      |> json.to_string,
    501,
  )
}
