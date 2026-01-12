//// This module contains the code to run the sql queries defined in
//// `./src/sql`.
//// > 🐿️ This module was generated automatically using v4.6.0 of
//// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
////

import gleam/dynamic/decode
import gleam/json.{type Json}
import gleam/option.{type Option}
import gleam/time/calendar.{type Date}
import gleam/time/timestamp.{type Timestamp}
import pog

/// Runs the `delete_image` query
/// defined in `./src/sql/delete_image.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn delete_image(
  db: pog.Connection,
  arg_1: String,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "delete from images where original_filename = $1;
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_image` query
/// defined in `./src/sql/get_image.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetImageRow {
  GetImageRow(
    original_filename: String,
    captured_at: Timestamp,
    original_metadata: String,
    local_path: String,
    day: Option(Date),
    sequence: Option(Int),
    public_filename: Option(String),
    created_at: Option(Timestamp),
    updated_at: Option(Timestamp),
  )
}

/// Runs the `get_image` query
/// defined in `./src/sql/get_image.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_image(
  db: pog.Connection,
  arg_1: String,
) -> Result(pog.Returned(GetImageRow), pog.QueryError) {
  let decoder = {
    use original_filename <- decode.field(0, decode.string)
    use captured_at <- decode.field(1, pog.timestamp_decoder())
    use original_metadata <- decode.field(2, decode.string)
    use local_path <- decode.field(3, decode.string)
    use day <- decode.field(4, decode.optional(pog.calendar_date_decoder()))
    use sequence <- decode.field(5, decode.optional(decode.int))
    use public_filename <- decode.field(6, decode.optional(decode.string))
    use created_at <- decode.field(7, decode.optional(pog.timestamp_decoder()))
    use updated_at <- decode.field(8, decode.optional(pog.timestamp_decoder()))
    decode.success(GetImageRow(
      original_filename:,
      captured_at:,
      original_metadata:,
      local_path:,
      day:,
      sequence:,
      public_filename:,
      created_at:,
      updated_at:,
    ))
  }

  "select * from images where original_filename = $1;
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `insert_image` query
/// defined in `./src/sql/insert_image.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn insert_image(
  db: pog.Connection,
  arg_1: String,
  arg_2: Timestamp,
  arg_3: Json,
  arg_4: String,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "insert into images
  (original_filename, captured_at, original_metadata, local_path)
values
  ($1, $2, $3, $4);
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.timestamp(arg_2))
  |> pog.parameter(pog.text(json.to_string(arg_3)))
  |> pog.parameter(pog.text(arg_4))
  |> pog.returning(decoder)
  |> pog.execute(db)
}
