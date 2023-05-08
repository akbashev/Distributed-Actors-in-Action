public struct TicketRequest: Codable {
  public let tickets: Int
  
  public init(
    tickets: Int
  ) {
    self.tickets = tickets
  }
}
