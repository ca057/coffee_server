import ansel/bounding_box
import ansel/image
import gleam/erlang/process
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/otp/actor
import gleam/result
import gleam/string
import snag
import wisp

pub type ProcessImageMessage {
  TransformImage(String)
}

fn extract_file_name_without_extension(path: String) -> Result(String, Nil) {
  string.split(path, "/")
  |> list.last
  |> result.try(fn(file_name) {
    string.split(file_name, ".")
    |> list.first
  })
}

// TODO: figure out how to overwrite the snag errors and get rid of them
// TODO: remove the case and make use of use
// TODO: proper file name based on EXIF data, add function to ensure that directory exists
fn process_image(images: List(String), message: ProcessImageMessage) {
  let _ = case message {
    TransformImage(image_path) -> {
      io.println("TransformImage (received): " <> image_path)

      use input_image <- result.try(image.read(image_path))
      let width = image.get_width(input_image)
      let height = image.get_height(input_image)

      case
        int.divide(height - width, 2),
        float.divide(int.to_float(300), int.to_float(width)),
        extract_file_name_without_extension(image_path)
      {
        Ok(top), Ok(scale), Ok(file_name) -> {
          use bounds <- result.try(bounding_box.ltwh(0, top, width, width))

          image.extract_area(input_image, bounds)
          |> result.try(image.scale(_, scale))
          |> result.try(image.write(
            _,
            "local/processed_images/" <> file_name,
            image.JPEG(100, True),
          ))
          |> result.try(fn(i) {
            wisp.log_info("TransformImage (finished): " <> i)
            Ok(i)
          })
          |> result.try_recover(fn(error) {
            wisp.log_error("TransformImage (failed): " <> error.issue)
            Error(error)
          })
        }
        _, _, _ -> {
          wisp.log_error(
            "TransformImage (failed): error when calculating the bounding box or scale factor",
          )
          Error(snag.new(
            "error when calculating the bounding box or scale factor",
          ))
        }
      }
    }
  }
  actor.continue(images)
}

pub fn start() -> Result(process.Subject(ProcessImageMessage), actor.StartError) {
  actor.start(actor.on_message(actor.new([]), process_image))
  |> result.map(fn(image_processor) { image_processor.data })
}
