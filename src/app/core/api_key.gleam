import wisp

pub opaque type ApiKey {
  ApiKey(inner: String)
}

pub fn new(s: String) -> ApiKey {
  case s != "" {
    True -> ApiKey(s)
    False -> ApiKey(wisp.random_string(64))
  }
}

pub fn is_same_string(api_key: ApiKey, other: String) -> Bool {
  api_key.inner == other
}
