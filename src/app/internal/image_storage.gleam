import gleam/result
import gleam/string
import simplifile

pub type StoredImage {
  StoredImage(full_path: String, file_name: String)
}

// TODO: error handling and logging!
// TODO: store_image_if_not_exists
pub fn store_image(
  source temp_source: String,
  // TODO: add destination
  file_name file_name: String,
  // TODO: return custom type
) -> Result(String, String) {
  let app_dir = get_app_dir()

  let path = case simplifile.is_directory(app_dir) {
    Ok(True) -> Ok(app_dir)
    _ -> {
      // TODO: separate errors
      case simplifile.create_directory_all(app_dir) {
        Ok(_) -> Ok(app_dir)
        Error(err) ->
          Error("Failed to create app_dir: " <> simplifile.describe_error(err))
      }
    }
  }

  case path {
    Ok(path) -> {
      let final_path = join_paths(path, file_name)

      simplifile.copy_file(temp_source, final_path)
      |> result.map(fn(_) { final_path })
      |> result.map_error(simplifile.describe_error)
    }
    Error(error) -> Error("can’t create app_dir: " <> error)
  }
}

fn get_app_dir() -> String {
  "local/unprocessed_images"
}

fn join_paths(a: String, b: String) -> String {
  let trimmed_b = case b {
    "/" <> r -> r
    _ -> b
  }
  case string.ends_with(a, "/") {
    True -> a <> trimmed_b
    False -> a <> "/" <> trimmed_b
  }
}
