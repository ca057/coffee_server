import envoy
import gleam/result

pub type Key {
  Interface
}

pub fn get(key: Key) {
  case key {
    Interface -> result.unwrap(envoy.get("INTERFACE"), "localhost")
  }
}
