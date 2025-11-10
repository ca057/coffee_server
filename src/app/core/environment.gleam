import gleam/result
import envoy

pub type Key {
  Host
}

pub fn get(key: Key) -> String {
  case key {
    Host -> result.lazy_unwrap(envoy.get("HOST"), fn() { "localhost" })
  }
}
