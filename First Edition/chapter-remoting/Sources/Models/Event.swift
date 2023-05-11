public struct Event: Codable {
  public let name: String
  public let tickets: Int
  
  public init(
    name: String,
    tickets: Int
  ) {
    self.name = name
    self.tickets = tickets
  }
}
