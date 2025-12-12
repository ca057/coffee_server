import gleam/erlang/process
import gleam/io
import gleam/otp/actor
import gleam/result

pub type ProcessImageMessage {
  TransformImage(String)
}

fn process_image(images: List(String), message: ProcessImageMessage) {
  case message {
    TransformImage(image) -> {
      io.println("TransformImage (received): " <> image)
      process.sleep(5000)
      io.println("TransformImage (finished): " <> image)
    }
  }
  actor.continue(images)
}

pub fn start() -> Result(process.Subject(ProcessImageMessage), actor.StartError) {
  actor.start(actor.on_message(actor.new([]), process_image))
  |> result.map(fn(image_processor) { image_processor.data })
}
