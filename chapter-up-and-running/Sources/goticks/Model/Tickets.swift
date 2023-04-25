import Vapor

struct Tickets: Content {
  let event: String
  let entries: [Ticket]
}
