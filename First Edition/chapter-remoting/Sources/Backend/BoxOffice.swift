import Distributed
import DistributedCluster
import Models

public distributed actor BoxOffice {
  
  public typealias ActorSystem = ClusterSystem
  
  private var sellers: [String: TicketSeller] = [:]
  
  /// Create an event
  distributed public func create(event: Event) async throws -> Event {
    guard sellers[event.name] == nil else { throw CreateEventError.eventExists }
    self.sellers[event.name] = TicketSeller(
      eventName: event.name,
      tickets: Array(0..<event.tickets)
        .map { Ticket(id: $0) }
    )
    return event
  }
  
  /// Get event by name
  distributed public func getEvent(name: String) async -> Event? {
    await sellers[name]?.getEvent()
  }
  
  /// Get all live events
  distributed public func getEvents() async -> [Event] {
    await withTaskGroup(of: Event.self) { group in
      for seller in self.sellers.values {
        group.addTask {
          await seller.getEvent()
        }
      }
      return await group
        .reduce(into: [], { $0.append($1)} )
    }
  }
  
  /// Buy tickets for an event
  distributed public func getTicketsForEvent(name: String, numberOfTickets: Int) async throws -> Tickets? {
    guard let seller = sellers[name] else { return .none }
    return try await seller.buy(tickets: numberOfTickets)
  }
  
  /// Cancel event by name
  distributed public func cancelEvent(name: String) {
    self.sellers
      .removeValue(forKey: name)
  }
}
