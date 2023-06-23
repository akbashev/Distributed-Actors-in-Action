import DistributedCluster

distributed actor PostalOfficeManager {
  
  distributed func message() async throws {
    let workerPool = try await WorkerPool(
      selector: .dynamic(.postalOffices),
      actorSystem: self.actorSystem
    )
    
    let messages = Array(
      repeating: PostalOffice.Message.guaranteed("payslip"),
      count: 1000
    )
    
    var results: [PostalOffice.Result] = []
    for message in messages.filter({ $0.isGuaranteed }) {
      results.append(try await workerPool.submit(work: message))
    }
    print(results)
  }
}
