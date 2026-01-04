import gleam/list
import gleam/option
import gleam/regexp
import gleam/result
import gleam/time/timestamp

pub fn date_time_original_to_timestamp(
  date_time_original: String,
) -> Result(timestamp.Timestamp, Nil) {
  regexp.from_string("(\\d{4}):(\\d{2}):(\\d{2})\\W(\\d{2}):(\\d{2}):(\\d{2})")
  |> result.map(regexp.scan(_, date_time_original))
  |> result.map_error(fn(_) { Nil })
  |> result.try(list.first)
  |> result.try(fn(m) {
    list.try_map(m.submatches, option.to_result(_, Nil))
    |> result.try(fn(parsed) {
      case parsed {
        [year, month, day, hour, minute, second] -> {
          timestamp.parse_rfc3339(
            year
            <> "-"
            <> month
            <> "-"
            <> day
            <> "T"
            <> hour
            <> ":"
            <> minute
            <> ":"
            <> second
            <> "Z",
          )
        }
        _ -> Error(Nil)
      }
    })
  })
}
