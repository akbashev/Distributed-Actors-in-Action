public struct Tickets: Codable {
  public let event: String
  public let entries: [Ticket]
  
  public init(
    event: String,
    entries: [Ticket]
  ) {
    self.event = event
    self.entries = entries
  }
}
