import app/lib/exif
import gleam/option
import gleam/result
import gleam/string
import gleam/time/timestamp
import glexif
import pog
import simplifile
import sql
import wisp

pub type StoredImageError {
  FileOperationError(String)
  UnknownError
}

pub type StoredImage {
  StoredImage(db_key: String, full_path: String)
}

// TODO: error handling and logging!
// TODO: store_image_if_not_exists
pub fn store_image(
  db: pog.Connection,
  file: wisp.UploadedFile,
) -> Result(StoredImage, StoredImageError) {
  let app_dir = get_app_dir()

  let exif_data = glexif.get_exif_data_for_file(file.path)

  use _ <- result.try(
    sql.insert_image(
      db,
      file.file_name,
      option.to_result(exif_data.date_time_original, Nil)
        |> result.try(exif.date_time_original_to_timestamp)
        |> result.unwrap(timestamp.system_time()),
      exif.export_to_json(exif_data),
    )
    |> result.map_error(fn(_) { UnknownError })
    |> result.try(fn(r) {
      // TODO: make this faile when it already exist
      case r.count {
        1 -> {
          Ok(Nil)
        }
        _ -> Error(UnknownError)
      }
    }),
  )

  use path <- result.try(case simplifile.is_directory(app_dir) {
    Ok(True) -> Ok(app_dir)
    _ -> {
      // TODO: separate errors
      case simplifile.create_directory_all(app_dir) {
        Ok(_) -> Ok(app_dir)
        Error(err) ->
          Error(FileOperationError(
            "Failed to create app_dir: " <> simplifile.describe_error(err),
          ))
      }
    }
  })
  let final_path = join_paths(path, file.file_name)

  simplifile.copy_file(file.path, final_path)
  |> result.map(fn(_) { StoredImage(file.file_name, final_path) })
  |> result.map_error(fn(err) {
    // TODO: rollback database when storing the file fails
    FileOperationError(
      "Failed to copy file: " <> simplifile.describe_error(err),
    )
  })
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
