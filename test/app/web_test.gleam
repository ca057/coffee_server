import app/core/api_key
import app/web
import gleam/http
import gleeunit
import wisp
import wisp/simulate

pub fn main() {
  gleeunit.main()
}

pub fn require_api_key_middleware_test() {
  let request = simulate.request(http.Get, "/")

  // ---
  // responds unauthenticated when other api key is passed in
  let unauthenticated_response =
    web.require_api_key_middleware(
      simulate.header(request, "authorization", "Bearer: some invalid api key"),
      api_key.new("expected api key"),
      fn(_, _) { wisp.ok() },
    )
  // TODO: compary body
  assert unauthenticated_response.status == 401

  // ---
  // handles request when expected API key is passed in
  let expected_api_key = "expected api key"
  let authenticated_response =
    web.require_api_key_middleware(
      simulate.header(request, "authorization", "Bearer: " <> expected_api_key),
      api_key.new(expected_api_key),
      fn(_, _) { wisp.ok() },
    )
  // TODO: compare body
  assert authenticated_response.status == 200
}
