import Models

actor TicketSeller {
  
  let eventName: String
  var tickets: [Ticket] = []
  
  /// Buy tickets from that seller
  func buy(tickets numberOfTickets: Int) throws -> Tickets {
    let entries = self.tickets.prefix(numberOfTickets)
    guard entries.count >= numberOfTickets else {
      throw BuyTicketsError.notEnoughTickets
    }
    self.tickets = Array(self.tickets[numberOfTickets..<self.tickets.count])
    return .init(
      event: self.eventName,
      entries: Array(entries)
    )
  }
  
  /// Check seller's event
  func getEvent() -> Event {
    Event(
      name: self.eventName,
      tickets: self.tickets.count
    )
  }
  
  /// Removed add(tickets:) method and directly passing tickets here.
  init(
    eventName: String,
    tickets: [Ticket] = []
  ) {
    self.eventName = eventName
    self.tickets = tickets
  }
}
