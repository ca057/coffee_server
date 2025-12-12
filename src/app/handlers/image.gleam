import app/core/api_key
import app/core/environment
import app/image_transform_actor
import app/services/image_storage
import app/web
import gleam/erlang/process
import gleam/http
import gleam/list
import gleam/otp/actor
import gleam/result
import wisp.{type Request, type Response}

pub fn handle_request(
  req: Request,
  subject: process.Subject(image_transform_actor.ProcessImageMessage),
) -> Response {
  use req, _ <- web.require_api_key_middleware(
    req,
    api_key.new(environment.get(environment.ApiKey)),
  )

  case req.method, wisp.path_segments(req) {
    // TODO: find a better structure
    http.Put, ["images"] -> handle_image_upload(req, subject)
    _, _ -> web.respond_with_error("not found", 404)
  }
}

fn handle_image_upload(
  req: Request,
  subject: process.Subject(image_transform_actor.ProcessImageMessage),
) -> Response {
  use formdata <- wisp.require_form(req)

  let result = {
    use file <- result.try(list.key_find(formdata.files, "image"))
    use path <- result.try(image_storage.store_image(
      source: file.path,
      file_name: file.file_name,
    ))

    actor.send(subject, image_transform_actor.TransformImage(path))

    wisp.log_info("file uploaded to " <> path)

    Ok(file.file_name)
  }

  case result {
    Ok(name) -> wisp.json_response(name, 200)
    Error(_) -> wisp.bad_request("invalid file or missing")
  }
}
