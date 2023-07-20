import Distributed
import DistributedCluster

typealias DefaultDistributedActorSystem = ClusterSystem

@main
public struct Words {
  
  public static func main() async throws {
    let director = await ClusterSystem("master")
    let aggregatorA = await ClusterSystem("node-a") { settings in
      settings.bindPort = 2222
    }
    let aggregatorB = await ClusterSystem("node-b") { settings in
      settings.bindPort = 3333
    }
        
    // Seeding nodes
    aggregatorA.cluster.join(endpoint: director.settings.endpoint)
    aggregatorB.cluster.join(endpoint: director.settings.endpoint)
//    aggregatorA.cluster.join(endpoint: aggregatorB.settings.endpoint)

    try await ensureCluster([director, aggregatorA, aggregatorB], within: .seconds(10))
      
    director.log.info("Joined?")
        
    let masterActor = try await Master(
      actorSystem: director
    )
    
    try await masterActor.start()
    var workersA: [Worker] = []
    for _ in 0..<9 {
      await workersA.append(Worker(actorSystem: aggregatorA))
    }
    
    var workersB: [Worker] = []
    for _ in 0..<9 {
      await workersB.append(Worker(actorSystem: aggregatorB))
    }

    try await director.terminated
  }
  
  private static func ensureCluster(_ systems: [ClusterSystem], within: Duration) async throws {
    let nodes = Set(systems.map(\.settings.bindNode))
    
    try await withThrowingTaskGroup(of: Void.self) { group in
      for system in systems {
        group.addTask {
          try await system.cluster.waitFor(nodes, .up, within: within)
        }
      }
      // loop explicitly to propagagte any error that might have been thrown
      for try await _ in group {
        
      }
    }
  }
}
