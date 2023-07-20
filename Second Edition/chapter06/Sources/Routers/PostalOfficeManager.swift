import Distributed
import DistributedCluster

distributed actor PostalOfficeManager {
  
  distributed func message() async throws {
    let workerPool = try await WorkerPool(
      selector: .dynamic(.postalOffices),
      actorSystem: self.actorSystem
    )
    
    let messages = Array(
      repeating: PostalOffice.Message.guaranteed("payslip"),
      count: 100
    )
    
    var results: [PostalOffice.Result] = []
    for message in messages.filter({ $0.isGuaranteed }) {
      results.append(try await workerPool.submit(work: message))
    }
    
    self.actorSystem.log
      .debug(
        .init(
          stringLiteral: results
            .map { $0.value }
            .joined(separator: ", ")
        )
      )
  }
}
