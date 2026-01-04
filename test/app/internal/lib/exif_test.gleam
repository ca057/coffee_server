import app/internal/lib/exif
import gleam/order
import gleam/result
import gleam/time/timestamp
import gleeunit/should

pub fn date_time_original_to_timestamp_test() {
  let expected = timestamp.parse_rfc3339("2019-02-11T08:45:40Z")

  let t =
    should.be_ok(exif.date_time_original_to_timestamp("2019:02:11 08:45:40"))

  expected
  |> result.map(timestamp.compare(_, t))
  |> result.map(should.equal(_, order.Eq))
}
