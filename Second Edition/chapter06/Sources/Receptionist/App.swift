import DistributedCluster

typealias DefaultDistributedActorSystem = ClusterSystem

@main
public struct App {
  public static func main() async throws {
    let clusterSystem = await ClusterSystem(settings: .default)
    let hotelConcierge = HotelConcierge(actorSystem: clusterSystem)
    try await hotelConcierge.listing()
    let mrX = VIPGuest(actorSystem: clusterSystem, name: "Mr.X")
    let mrY = VIPGuest(actorSystem: clusterSystem, name: "Mr.Y")
    try await mrX.enterHotel()
    try await mrY.enterHotel()
    if let guest = try await hotelConcierge.findGuest(with: "Mr.X") {
      clusterSystem.log.debug("Found guest: \(guest)")
    }
    clusterSystem.log.debug("Press anything to terminate:")
    _ = readLine()
  }
}
