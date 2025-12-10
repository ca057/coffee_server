import app/core/api_key
import app/core/environment
import app/web
import gleam/http
import gleam/list
import gleam/result
import wisp.{type Request, type Response}

pub fn handle_request(req: Request) -> Response {
  use req, _ <- web.require_api_key_middleware(
    req,
    api_key.new(environment.get(environment.ApiKey)),
  )

  case req.method, wisp.path_segments(req) {
    // TODO: find a better structure
    http.Put, ["images"] -> handle_image_upload(req)
    _, _ -> web.respond_with_error("not found", 404)
  }
}

fn handle_image_upload(req: Request) -> Response {
  use formdata <- wisp.require_form(req)

  let result = {
    use file <- result.try(list.key_find(formdata.files, "image"))

    wisp.log_info("file uploaded to " <> file.path)

    Ok(file.file_name)
  }

  case result {
    Ok(name) -> wisp.json_response(name, 200)
    Error(_) -> wisp.bad_request("invalid file or missing")
  }
}
