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
  ReadingExifError(String)
  UnknownError
}

pub type StoredImage {
  StoredImage(id: String)
}

// TODO: error handling and logging!
// TODO: store_image_if_not_exists
pub fn store_image(
  db: pog.Connection,
  file: wisp.UploadedFile,
) -> Result(StoredImage, StoredImageError) {
  let app_dir = get_app_dir()

  use path <- result.try(case simplifile.is_directory(app_dir) {
    Ok(True) -> Ok(app_dir)
    _ -> {
      case simplifile.create_directory_all(app_dir) {
        Ok(_) -> Ok(app_dir)
        Error(err) ->
          Error(FileOperationError(
            "Failed to create app_dir: " <> simplifile.describe_error(err),
          ))
      }
    }
  })
  let local_path = join_paths(path, file.file_name)

  use exif_data <- result.try(
    glexif.get_exif_data_for_file(file.path)
    |> result.map_error(fn(e) { ReadingExifError(glexif.error_to_string(e)) }),
  )

  let date_time_original =
    case exif_data.date_time_original {
      option.Some(dto) -> exif.date_time_original_to_timestamp(dto)
      _ -> Error(Nil)
    }
    |> result.lazy_unwrap(timestamp.system_time)

  use _ <- result.try(
    sql.insert_image(
      db,
      file.file_name,
      date_time_original,
      exif.export_to_json(exif_data),
      local_path,
    )
    |> result.map_error(fn(_) { UnknownError })
    |> result.try(fn(r) {
      echo r
      case r.count {
        1 -> {
          Ok(Nil)
        }
        _ -> Error(UnknownError)
      }
    }),
  )

  simplifile.copy_file(file.path, local_path)
  |> result.map(fn(_) { StoredImage(file.file_name) })
  |> result.map_error(fn(err) {
    case sql.delete_image(db, file.file_name) {
      Ok(_) ->
        FileOperationError(
          "Failed to copy file to storage: " <> simplifile.describe_error(err),
        )
      Error(_) ->
        FileOperationError(
          "Failed to copy file to storage and failed to rollback image from database: "
          <> simplifile.describe_error(err),
        )
    }
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
