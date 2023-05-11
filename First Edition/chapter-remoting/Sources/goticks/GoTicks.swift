import Distributed
import DistributedCluster
import Vapor
import Backend
import Frontend

@main
public struct GoTicks {
  public private(set) var text = "Hello, World!"
  
  public static func main() async throws {
    let app = try Application(.detect())
    defer { app.shutdown() }
    let system = await ClusterSystem("backend") { settings in
      settings.endpoint.host = "127.0.0.1"
      settings.endpoint.port = 7337
    }
    
    let boxOffice = BoxOffice(actorSystem: system)
    try routes(
      app: app,
      api: .live(boxOffice: boxOffice)
    )
    try app.run()
  }
}


extension BoxOfficeApi {
  public static func live(
    boxOffice: BoxOffice
  ) -> BoxOfficeApi {
    BoxOfficeApi(
      createEvent: { return try await boxOffice.create(event: .init(name: $0, tickets: $1)) },
      getEvents: { return try await boxOffice.getEvents() },
      getEvent: { return try await boxOffice.getEvent(name: $0) },
      cancelEvent: { return try await boxOffice.cancelEvent(name: $0) },
      requestTickets: { return try await boxOffice.getTicketsForEvent(name: $0, numberOfTickets: $1) }
    )
  }
}
