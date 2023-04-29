import FoundationEssentials

enum DbStrategy2 {
  static func main() async throws {
//    let sources = [
//      "file:///source1/",
//      "file:///source2/"
//    ]
//    let databaseUrls = [
//      "http://mydatabase1",
//      "http://mydatabase2",
//      "http://mydatabase3"
//    ]
//    let logProcessing = LogProcessingSupervisor(
//      sources: sources,
//      databaseUrls: databaseUrls
//    )
//    try await system.terminated
  }
  
  actor LogProcessingSupervisor {
    
    let databaseUrls: [String]
    var fileWatchers: [String: FileWatcher]
    
    func log(_ file: Data) async throws {
      for wathcher in fileWatchers {
        do {
          try await wathcher.value
            .newFile(
              file,
              timeAdded: Date.timeIntervalBetween1970AndReferenceDate
            )
        } catch {
          switch error {
            case TerminationError.terminateFileWatcher:
              try self.abandon(source: wathcher.key)
            case LogProcessingError.diskError:
              throw TerminationError.terminateLogProcessing
            default:
              // Throw further
              throw error
          }
        }
      }
    }
    
    func abandon(source: String) throws {
      self.fileWatchers.removeValue(forKey: source)
      if self.fileWatchers.isEmpty {
        throw TerminationError.terminateLogProcessing
      }
    }
    
    init(
      sources: [String],
      databaseUrls: [String]
    ) throws {
      self.databaseUrls = databaseUrls
      self.fileWatchers = try sources
        .reduce(
          into: [:], {
            $0[$1] = try FileWatcher(
              source: $1,
              databaseUrls: databaseUrls
            )
          }
        )
    }
  }
  
  actor FileWatcher: FileWatchingAbilities {
    
    let source: String
    // Keep track of databaseurl for restarting child nodes
    var databaseUrls: [String]
    var logProcessor: LogProcessor
    
    func newFile(_ file: Data, timeAdded: TimeInterval) async throws {
      do {
        try await self.logProcessor.log(LogFile(file: file))
      } catch {
        switch error {
          case LogProcessingError.dbNodeDownException:
            throw TerminationError.terminateFileWatcher
          case LogProcessingError.dbBrokenConnectionException:
            guard let databaseUrl = databaseUrls.first else {
              throw TerminationError.terminateFileWatcher
            }
            self.logProcessor = .init(databaseUrl: databaseUrl)
            self.databaseUrls.removeFirst()
            // Call itself again
            try await self.newFile(file, timeAdded: timeAdded)
          default:
            // Continue throwing
            throw error
        }
      }
    }
    
    init(
      source: String,
      databaseUrls: [String]
    ) throws {
      guard let databaseUrl = databaseUrls.first else {
        throw LogProcessingError.configurationException(msg: "Provide database urls.")
      }
      self.source = source
      self.databaseUrls = databaseUrls
      self.logProcessor = .init(databaseUrl: databaseUrl)
    }
  }
  
  actor LogProcessor: LogParsing {
    
    var dbWriter: DbWriter

    func log(_ file: LogFile) async throws {
      let lines = try self.parse(file: file)
      try await withThrowingTaskGroup(of: Void.self) { group in
        for line in lines {
          group.addTask {
            try await self.dbWriter.write(line)
          }
          try await group.waitForAll()
        }
      }
    }
    
    init(
      databaseUrl: String
    ) {
      self.dbWriter = DbWriter(databaseUrl: databaseUrl)
    }
  }
  
  actor DbWriter {
    
    let connection: DbCon
    
    func write(_ line: Line) throws {
      try connection.write(
        [
          "time": line.time,
          "message": line.message,
          "messageType": line.messageType
        ]
      )
    }
    
    init(
      databaseUrl: String
    ) {
      self.connection = .debug(databaseUrl)
    }
  }
}
