import Distributed
import Vapor

@main
public struct GoTicks {
  public private(set) var text = "Hello, World!"
  
  public static func main() async throws {
    let app = try Application(.detect())
    defer { app.shutdown() }
    let boxOffice = BoxOffice()
    try routes(
      app: app,
      api: .live(boxOffice: boxOffice)
    )
    try app.run()
  }
}
