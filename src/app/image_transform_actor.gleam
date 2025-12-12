import gleam/erlang/process
import gleam/io
import gleam/otp/actor

pub type ProcessImageMessage {
  TransformImage(String)
}

pub fn process_image(images: List(String), message: ProcessImageMessage) {
  case message {
    TransformImage(image) -> {
      io.println("transforming image (received): " <> image)
      process.sleep(5000)
      io.println("transforming image (finished): " <> image)
    }
  }
  actor.continue(images)
}
