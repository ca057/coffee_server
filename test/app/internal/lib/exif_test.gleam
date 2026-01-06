import app/internal/lib/exif
import gleam/order
import gleam/time/timestamp
import gleeunit/should

pub fn date_time_original_to_timestamp_test() {
  let assert Ok(earlier) = timestamp.parse_rfc3339("2019-02-10T08:45:40Z")
  let assert Ok(expected) = timestamp.parse_rfc3339("2019-02-11T08:45:40Z")
  let assert Ok(later) = timestamp.parse_rfc3339("2019-02-12T08:45:40Z")

  let t =
    should.be_ok(exif.date_time_original_to_timestamp("2019:02:11 08:45:40"))

  should.equal(timestamp.compare(earlier, t), order.Lt)
  should.equal(timestamp.compare(expected, t), order.Eq)
  should.equal(timestamp.compare(later, t), order.Gt)
}
