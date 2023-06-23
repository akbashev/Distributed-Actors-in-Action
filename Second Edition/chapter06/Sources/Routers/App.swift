import DistributedCluster

typealias DefaultDistributedActorSystem = ClusterSystem

@main
public struct App {
  public static func main() async throws {
    let actorSystem = await ClusterSystem()
    let manager = PostalOfficeManager(actorSystem: actorSystem)
    Task.detached { try await manager.message() }
    try await Task.sleep(for: .seconds(3))
    let worker1 = PostalOffice(actorSystem: actorSystem)
    let worker2 = PostalOffice(actorSystem: actorSystem)
    let worker3 = PostalOffice(actorSystem: actorSystem)
    let worker4 = PostalOffice(actorSystem: actorSystem)
    
    for worker in [worker1, worker2, worker3, worker4] {
      await actorSystem.receptionist.checkIn(worker, with: .postalOffices)
    }
    _ = readLine()
  }
}
