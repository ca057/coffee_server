import gleam/result
import simplifile

fn get_app_dir() -> String {
  todo
}

pub fn copy_file_to_app(
  temp_source: String,
  file_name: String,
) -> Result(String, String) {
  let app_dir = get_app_dir()

  let path = case simplifile.is_directory(app_dir) {
    Ok(True) -> Ok(app_dir)
    _ -> {
      // TODO: separate errors
      case simplifile.create_directory(app_dir) {
        Ok(_) -> Ok(app_dir)
        Error(err) ->
          Error("Failed to create app_dir: " <> simplifile.describe_error(err))
      }
    }
  }

  case path {
    Ok(path) -> {
      // TODO: fix
      let final_path = path <> "/" <> file_name
      let r = simplifile.copy_file(temp_source, final_path)

      Ok(final_path)
    }
    Error(err) -> Error(err)
  }
}
