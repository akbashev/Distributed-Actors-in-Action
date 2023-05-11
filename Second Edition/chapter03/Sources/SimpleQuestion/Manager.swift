actor Manager {
  
  private typealias WorkerID = String
  private lazy var workers: [WorkerID: Worker] = [:]
  
  func delegate(texts: [String]) async {
    self.workers = texts.reduce(into: [:], { $0[$1] = Worker() })
    _ = await withTaskGroup(of: Void.self) { group in
      for worker in self.workers {
        group.addTask {
          let (worker, text) = (worker.value, worker.key)
          print("Sending text \(text) to worker.")
          do {
            /// Unfortunetly we don't yet? have built-in support for timeouts in Swift Tasks.
            /// So a bit of overhead.
            try await async(timeout: .seconds(3)) {
              try await worker.parse(text: text)
            }
            await self.report(description: "\(text) read by \(worker)")
          } catch {
            await self.report(description: "Parsing \(text) has failed with \(error)")
          }
        }
      }
      return await group
        .reduce(into: [], { $0.append($1)} )
    }
  }
  
  func report(description: String) {
    print(description)
  }
}

struct TimedOutError: Error, Equatable {}

func `async`<R>(
  timeout: Duration,
  _ work: @escaping () async throws -> R
) async throws -> R {
  try await withThrowingTaskGroup(of: R.self) { group in
    group.addTask {
      return try await work()
    }
    group.addTask {
      try await Task.sleep(for: timeout)
      try Task.checkCancellation()
      throw TimedOutError()
    }
    // First finished child task wins, cancel the other task.
    let result = try await group.next()!
    group.cancelAll()
    return result
  }
}
