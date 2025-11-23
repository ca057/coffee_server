import app/core/api_key
import gleam/io
import gleam/json
import gleam/list
import gleam/result
import gleam/string
import wisp

pub fn middleware(
  req: wisp.Request,
  handle_request: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  use req <- wisp.csrf_known_header_protection(req)

  handle_request(req)
}

pub fn respond_with_error(error_message: String, code: Int) -> wisp.Response {
  wisp.json_response(
    build_error_res_body(error_message) |> json.to_string,
    code,
  )
}

pub fn require_api_key_middleware(
  req: wisp.Request,
  required_api_key: api_key.ApiKey,
  handle_request: fn(wisp.Request, api_key.ApiKey) -> wisp.Response,
) -> wisp.Response {
  let auth =
    list.find(req.headers, fn(header) {
      string.lowercase(header.0) == "authorization"
    })
    |> result.map(fn(auth_header) {
      let extracted_key =
        string.drop_start(auth_header.1, string.length("Bearer: "))

      case api_key.is_same_string(required_api_key, extracted_key) {
        True -> Ok(required_api_key)
        False -> Error(Nil)
      }
    })
    |> result.flatten

  case auth {
    Ok(extracted_api_key) -> {
      handle_request(req, extracted_api_key)
    }
    Error(_) -> respond_with_error("unauthenticated", 401)
  }
}

pub fn build_error_res_body(message: String) -> json.Json {
  json.object([#("error", json.string(message))])
}
