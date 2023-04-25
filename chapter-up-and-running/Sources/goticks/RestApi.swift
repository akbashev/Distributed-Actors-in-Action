import Vapor

/// Routing rules of the app
func routes(
  app: Application,
  api: BoxOfficeApi
) throws {
  app.get("hello") { req in
      return "Hello, world."
  }
  app.get("events") { _ in
    try await api.getEvents()
  }
  let events = app.grouped("events")
  events.get(":event") { req in
    guard let event = req.parameters.get("event"),
          let event = try await api.getEvent(event) else { throw Abort(.badRequest) }
    return event
  }
  events.post(":event") { req in
    guard let event = req.parameters.get("event") else { throw Abort(.badRequest) }
    let eventDescription = try req.content.decode(EventDescription.self)
    guard eventDescription.tickets > 0 else { throw Abort(.badRequest) }
    return try await api.createEvent(event, eventDescription.tickets)
  }
  events.delete(":event") { req in
    guard let event = req.parameters.get("event") else { throw Abort(.badRequest) }
    try await api.cancelEvent(event)
    return "Success"
  }
  events.post(":event", "tickets") { req in
    guard let event = req.parameters.get("event", as: String.self) else { throw Abort(.badRequest) }
    let ticketRequest = try req.content.decode(TicketRequest.self)
    guard ticketRequest.tickets > 0,
          let tickets = try await api.requestTickets(event, ticketRequest.tickets) else { throw Abort(.badRequest) }
    return tickets
  }
}

/// Protocol Witness Pointfree.co's style
/// https://www.pointfree.co/collections/protocol-witnesses/alternatives-to-protocols
struct BoxOfficeApi {
  let createEvent: (String, Int) async throws -> Event
  let getEvents: () async throws -> [Event]
  let getEvent: (String) async throws -> Event?
  let cancelEvent: (String) async throws -> ()
  let requestTickets: (String, Int) async throws -> Tickets?
}

extension BoxOfficeApi {
  static func live(
    boxOffice: BoxOffice
  ) -> BoxOfficeApi {
    BoxOfficeApi(
      createEvent: { return try await boxOffice.create(event: .init(name: $0, tickets: $1)) },
      getEvents: { return await boxOffice.getEvents() },
      getEvent: { return await boxOffice.getEvent(name: $0) },
      cancelEvent: { return await boxOffice.cancelEvent(name: $0) },
      requestTickets: { return try await boxOffice.getTicketsForEvent(name: $0, numberOfTickets: $1) }
    )
  }
}
