import FoundationEssentials

enum DbStrategy1 {
  
  static func main() async throws {
//    let sources = [
//      "file:///source1/",
//      "file:///source2/"
//    ]
//    let databaseUrl = "http://mydatabase1"
//    let logProcessing = LogProcessingSupervisor(
//      sources: sources,
//      databaseUrl: databaseUrl
//    )
//    try await system.terminated
  }
  
  actor LogProcessingSupervisor {
    
    let databaseUrl: String
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
          try self.abandon(source: wathcher.key)
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
      databaseUrl: String
    ) {
      self.databaseUrl = databaseUrl
      self.fileWatchers = sources
        .reduce(
          into: [:], {
            $0[$1] = FileWatcher(
              source: $1,
              logProcessor: .init(
                dbWriter: .init(
                  databaseUrl: databaseUrl
                )
              )
            )
          }
        )
    }
  }
  
  actor FileWatcher: FileWatchingAbilities {
    
    let source: String
    let logProcessor: LogProcessor
    
    func newFile(
      _ file: Data,
      timeAdded: TimeInterval
    ) async throws {
      try await self.logProcessor.log(LogFile(file: file))
    }
    
    init(
      source: String,
      logProcessor: LogProcessor
    ) {
      self.source = source
      self.logProcessor = logProcessor
      // Why we need this? 🤔
      self.register(uri: source)
    }
  }
  
  actor LogProcessor: LogParsing {
    
    let dbWriter: DbWriter
    
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
      dbWriter: DbWriter
    ) {
      self.dbWriter = dbWriter
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

struct LogFile: Codable, Equatable {
  let file: Data
}

struct Line: Codable, Equatable {
  let time: TimeInterval
  let message: String
  let messageType: String
}

struct DbCon {
  let write: ([String: Any]) throws -> ()
  let close: () throws -> ()
}

extension DbCon {
  static func debug(_ url: String) -> DbCon {
    DbCon(
      write: { _ in },
      close: {}
    )
  }
}

protocol LogParsing {
  // Parses log files. creates line objects from the lines in the log file.
  // If the file is corrupt a CorruptedFileException is thrown
  func parse(file: LogFile) throws -> [Line]
}

// Don't like it being default behaviour for typeclass(protocol)—hidden implementation.
// For now just copied.
// TODO: Maybe refactor
extension LogParsing {
  // implement parser here, now just return dummy value
  func parse(file: LogFile) throws -> [Line] {
    do {
      return try JSONDecoder()
        .decode([Line].self, from: file.file)
    } catch {
      throw LogProcessingError.corruptedFileException(
        msg: "Corrupted file",
        file: file
      )
    }
  }
}

// Why we need this?
protocol FileWatchingAbilities {
  func register(uri: String)
}

extension FileWatchingAbilities {
  func register(uri: String) {}
}

// PoisonPill kinda, escalates termination to parent actors
enum TerminationError: Error {
  case terminateFileWatcher
  case terminateLogProcessing
}

enum LogProcessingError: Codable, Error {
  case diskError(msg: String)
  case corruptedFileException(msg: String, file: LogFile)
  case dbBrokenConnectionException(msg: String)
  case dbNodeDownException(msg: String)
  case configurationException(msg: String)
}
