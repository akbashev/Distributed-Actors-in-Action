public struct EventDescription: Codable {
  public let tickets: Int
  
  public init(
    tickets: Int
  ) {
    self.tickets = tickets
  }
}
