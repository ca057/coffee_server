import envoy
import gleam/result
import wisp

pub type Key {
  Interface
  ApiKey
}

pub fn get(key: Key) {
  case key {
    Interface -> result.unwrap(envoy.get("INTERFACE"), "localhost")
    ApiKey ->
      result.lazy_unwrap(envoy.get("API_KEY"), fn() {
        wisp.log_emergency("API_KEY not set in environment")
        wisp.random_string(64)
      })
  }
}
