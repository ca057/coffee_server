import app/core/api_key
import app/core/environment
import app/internal/image_storage
import app/internal/image_transform_actor
import app/web
import gleam/erlang/process
import gleam/http
import gleam/json
import gleam/list
import gleam/otp/actor
import gleam/result
import pog
import sql
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: web.Context) -> Response {
  use req, _ <- web.require_api_key_middleware(
    req,
    api_key.new(environment.get(environment.ApiKey)),
  )

  case req.method, wisp.path_segments(req) {
    // TODO: find a better structure
    http.Put, ["images"] -> handle_image_upload(req, ctx.db, ctx.subject)
    _, _ -> web.respond_with_error("not found", 404)
  }
}

fn overwrite_error_with_string(
  message: String,
) -> fn(Result(a, b)) -> Result(a, String) {
  // TODO: get rid of this function
  fn(a) { result.map_error(a, fn(_) { message }) }
}

fn handle_image_upload(
  req: Request,
  db: pog.Connection,
  subject: process.Subject(image_transform_actor.ProcessImageMessage),
) -> Response {
  use formdata <- wisp.require_form(req)

  let result = {
    use file <- result.try(
      list.key_find(formdata.files, "image")
      |> overwrite_error_with_string("cannot find image in request"),
    )

    case sql.get_image(db, file.file_name) {
      Ok(r) -> {
        case r.count {
          0 -> {
            // TODO: store image in DB
            use path <- result.try(
              image_storage.store_image(
                source: file.path,
                file_name: file.file_name,
              )
              // TODO: rollback image from DB
              |> overwrite_error_with_string("error storing image"),
            )

            actor.send(subject, image_transform_actor.TransformImage(path))

            wisp.log_info("file uploaded to " <> path)

            Ok(Nil)
          }
          _ -> Error("image file already exists")
        }
      }
      Error(_) -> Error("error querying if image exists")
    }
  }

  case result {
    Ok(_) ->
      wisp.json_response(
        json.object([
          #(
            "message",
            json.string(
              "image uploaded and transformation triggered successfully",
            ),
          ),
        ])
          |> json.to_string,
        200,
      )
    Error(error) -> wisp.bad_request(error)
  }
}
