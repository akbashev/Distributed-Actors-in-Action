import Distributed
import DistributedCluster

distributed actor Worker: DistributedWorker {
  
  distributed func submit(
    work: String
  ) async throws -> [String: Int] {
    self.actorSystem.log.info("processing on port \(self.actorSystem.settings.bindPort)")
    return work
    /// Don't wanna dig into regex, just splitted by space into words.
      .split(separator: " ")
      .map(String.init)
      .reduce(into: [String:Int]()) { acc, word in
        acc[word, default: 0] += 1
      }
  }
  
  init(actorSystem: ClusterSystem) async {
    self.actorSystem = actorSystem
    await actorSystem.receptionist.checkIn(self, with: .workers)
  }
}

extension DistributedReception.Key {
  static var workers: DistributedReception.Key<Worker> { "workers" }
}
