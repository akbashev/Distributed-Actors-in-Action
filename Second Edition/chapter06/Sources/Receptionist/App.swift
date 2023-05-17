import DistributedCluster

typealias DefaultDistributedActorSystem = ClusterSystem

@main
public struct GoTicks {  
  public static func main() async throws {
    let clusterSystem = await ClusterSystem(settings: .default)
    let hotelConcierge = HotelConcierge(actorSystem: clusterSystem)
    try await hotelConcierge.listing()
    let mrX = VIPGuest(actorSystem: clusterSystem, name: "Mr.X")
    let mrY = VIPGuest(actorSystem: clusterSystem, name: "Mr.Y")
    try await mrX.enterHotel()
    try await mrY.enterHotel()
    print("Found guest: \(try await hotelConcierge.findGuest(with: "Mr.X"))")
    print("Press anything to terminate:")
    _ = readLine()
  }
}
