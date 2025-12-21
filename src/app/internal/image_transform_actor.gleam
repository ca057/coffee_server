import ansel/bounding_box
import ansel/image
import gleam/erlang/process
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/otp/actor
import gleam/result
import gleam/string
import glexif
import simplifile
import snag
import wisp

pub type ProcessImageMessage {
  TransformImage(String)
}

fn map_snag_to_string(r: Result(a, snag.Snag)) -> Result(a, String) {
  result.map_error(r, fn(e) { e.issue })
}

fn overwrite_error_with_string(
  message: String,
) -> fn(Result(a, b)) -> Result(a, String) {
  fn(a) { result.map_error(a, fn(_) { message }) }
}

fn get_compact_date_for_image(path: String) -> Result(String, String) {
  case glexif.get_exif_data_for_file(path).date_time_original {
    option.Some(date_time) ->
      string.split(date_time, " ")
      |> list.first
      |> result.try(fn(date) { Ok(string.concat(string.split(date, ":"))) })
      |> overwrite_error_with_string(
        "failed to constract date in ISO format for image at path: " <> path,
      )
    _ ->
      Error(
        "failed to extract date_time_original from image at given path: "
        <> path,
      )
  }
}

// TODO: add author back to image metadata
// TODO: upload image to CDN in separate actor?
fn process_image(images: List(String), message: ProcessImageMessage) {
  let output_dir = "local/processed_images"

  let result = case message {
    TransformImage(image_path) -> {
      io.println("TransformImage (received): " <> image_path)

      use _ <- result.try(
        simplifile.create_directory_all(output_dir)
        |> overwrite_error_with_string("error when creating output directory"),
      )

      use input_image <- result.try(map_snag_to_string(image.read(image_path)))
      let width = image.get_width(input_image)

      use bounds <- result.try(
        int.divide(image.get_height(input_image) - width, 2)
        |> overwrite_error_with_string(
          "error when calculating top of bounding box",
        )
        |> result.try(fn(t) {
          map_snag_to_string(bounding_box.ltwh(0, t, width, width))
        }),
      )
      use scale <- result.try(
        float.divide(int.to_float(300), int.to_float(width))
        |> overwrite_error_with_string("error when calculating scaling factor"),
      )
      use file_name <- result.try(
        get_compact_date_for_image(image_path)
        // TODO: we need the count of the day to construct the full path
        |> result.try(fn(date_time) { Ok(date_time <> "0") }),
      )

      map_snag_to_string(image.extract_area(input_image, bounds))
      |> result.try(fn(i) { map_snag_to_string(image.scale(i, scale)) })
      |> result.try(fn(i) {
        map_snag_to_string(image.write(
          i,
          output_dir <> "/" <> file_name,
          image.JPEG(100, False),
        ))
      })
    }
  }

  case result {
    Ok(r) -> {
      wisp.log_info("TransformImage (finished): " <> r)
    }
    Error(error) -> {
      // TODO: act on result -> in case of error send a notification
      wisp.log_error("TransformImage (failed): " <> error)
    }
  }

  actor.continue(images)
}

pub fn start() -> Result(process.Subject(ProcessImageMessage), actor.StartError) {
  actor.start(actor.on_message(actor.new([]), process_image))
  |> result.map(fn(image_processor) { image_processor.data })
}
