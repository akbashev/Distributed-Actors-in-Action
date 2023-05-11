public struct Ticket: Codable, Equatable {
  public let id: Int
  
  public init(
    id: Int
  ) {
    self.id = id
  }
}
