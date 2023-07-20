import Distributed
import DistributedCluster

distributed actor Master {
  
  struct CountedWords: Sendable, Equatable {
    let aggregation: [String: Int]
  }
  
  struct FailedJob: Error, Equatable {
    let text: String
  }
  
  let worker: WorkerPool
  var countedWords: [String: Int] = [:]
  var lag: [String] = []
  
  private var timerTask: Task<Void, Error>?
  
  /// Monster 👹
  distributed func start() {
    if self.timerTask != .none { self.stop() }
    self.timerTask = Task { [weak self] in
      try await self?.timer()
    }
    Task.detached {
      try await self.timerTask?.value
    }
  }
  
  distributed func stop() {
    self.timerTask?.cancel()
    self.timerTask = .none
  }
  
  distributed func tick() async {
    self.actorSystem.log.debug("tick, current lag \(self.lag.count)")
    let paralellism = 20
    let text = "this simulates a stream, a very simple stream"
    let allTexts = self.lag + [text]
    let (firstPart, secondPart) = (
      allTexts[safe: 0..<paralellism] ?? [],
      allTexts[safe: paralellism..<Swift.max(paralellism, allTexts.count)] ?? []
    )
    for text in firstPart {
      do {
        async let aggregation = try await RemoteCall.with(timeout: .seconds(5)) {
          try await self.worker.submit(work: text)
        }
        self.countedWords = self.merge(
          currentCount: self.countedWords,
          newCount2Add: try await aggregation
        )
        print(self.countedWords)
        self.actorSystem.log
          .debug("current count $\(self.countedWords.count)")
      } catch {
        self.actorSystem.log
          .debug("failed, adding text to lag \(lag.count)")
        self.lag.append(text)
      }
    }
    self.lag.append(contentsOf: secondPart)
  }
  
  /// Just a recursive function that calls itself once per second.
  /// Don't think it's precise though, you can also try AsyncTimerSequence from AsyncAlgorithms package.
  distributed private func timer() async throws {
    try await Task.sleep(for: .seconds(1))
    guard !Task.isCancelled else { return }
    async let _  = await self.tick()
    try await self.timer()
  }
  
  private func merge(
    currentCount: [String: Int],
    newCount2Add: [String: Int]
  ) -> [String: Int] {
    newCount2Add
      .reduce(into: currentCount) { dict, keyValue in
        dict[keyValue.key] = keyValue.value
      }
  }
  
  init(
    actorSystem: ClusterSystem
  ) async throws {
    self.actorSystem = actorSystem
    self.worker = await WorkerPool(
      actorSystem: actorSystem
    )
  }
  
  deinit {
    self.timerTask?.cancel()
    self.timerTask = .none
  }
}

extension Array {
  subscript(safe range: Range<Index>) -> ArraySlice<Element>? {
    if range.endIndex > endIndex {
      if range.startIndex >= endIndex {
        return nil
      } else {
        return self[range.startIndex..<endIndex]
      }
    }
    else {
      return self[range]
    }
  }
}
