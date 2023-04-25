import Vapor

struct Event: Content {
  let name: String
  let tickets: Int
}
