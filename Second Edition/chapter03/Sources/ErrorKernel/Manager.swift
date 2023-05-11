actor Manager {
  
  private typealias WorkerID = String
  private lazy var workers: [WorkerID: Worker] = [:]
  
  func delegate(texts: [String]) async {
    self.workers = texts.reduce(into: [:], { $0[$1] = Worker() })
    /// Wouldn't model this like this myself, but making same implementation in the sake of learning.
    /// Order of parsing is not guaranteed, though.
    _ = await withTaskGroup(of: String.self) { group in
      for worker in self.workers {
        group.addTask {
          let (worker, text) = (worker.value, worker.key)
          print("Sending text \(text) to worker.")
          let parsedText = await worker.parse(text: text)
          print("Text \(parsedText) has been finished.")
          return parsedText
        }
      }
      return await group
        .reduce(into: [], { $0.append($1)} )
    }
  }
}
