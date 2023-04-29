import FoundationEssentials

enum DbStrategy3 {
  static func main() throws {
    let sources = [
      "file:///source1/",
      "file:///source2/"
    ]
    let databaseUrl = "http://mydatabase"
    
    // create the props and dependencies
    let writer = DbWriter(databaseUrl: databaseUrl)
    let dbSuper = DbSupervisor(writer: writer)
    let logProcSuper = LogProcSupervisor(dbSuper)
    let topLevelProps = FileWatcherSupervisor(
      sources: sources,
      logProcSupervisor: logProcSuper
    )
  }
  
  actor FileWatcherSupervisor {
    
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
            case LogProcessingError.diskError:
              throw TerminationError.terminateLogProcessing
            case TerminationError.terminateFileWatcher:
              try self.abandon(source: wathcher.key)
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
      logProcSupervisor: LogProcSupervisor
    ) {
      self.fileWatchers = sources
        .reduce(
          into: [:], {
            $0[$1] = FileWatcher(
              source: $1,
              logProcSupervisor: logProcSupervisor
            )
          }
        )
    }
  }
  
  actor FileWatcher: FileWatchingAbilities {
    
    let source: String
    var logProcSupervisor: LogProcSupervisor
    
    func newFile(_ file: Data, timeAdded: TimeInterval) async throws {
      try await self.logProcSupervisor.log(LogFile(file: file))
    }
    
    init(
      source: String,
      logProcSupervisor: LogProcSupervisor
    ) {
      self.source = source
      self.logProcSupervisor = logProcSupervisor
      self.register(uri: source)
    }
  }
  
  actor LogProcSupervisor {
    
    let dbSupervisor: DbSupervisor
    lazy var logProcessor = LogProcessor(dbSupervisor)
    
    func log(_ file: LogFile) async throws {
      do {
        try await self.logProcessor.log(file)
      } catch {
        switch error {
          case LogProcessingError.corruptedFileException:
            break
          default:
            throw error
        }
      }
    }
    
    init(
      _ dbSupervisor: DbSupervisor
    ) {
      self.dbSupervisor = dbSupervisor
    }
  }
  
  actor LogProcessor: LogParsing {
    
    var dbSupervisor: DbSupervisor
    
    func log(_ file: LogFile) async throws {
      let lines = try self.parse(file: file)
      try await withThrowingTaskGroup(of: Void.self) { group in
        for line in lines {
          group.addTask {
            try await self.dbSupervisor.write(line)
          }
          try await group.waitForAll()
        }
      }
    }
    
    init(
      _ dbSupervisor: DbSupervisor
    ) {
      self.dbSupervisor = dbSupervisor
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
  
  actor DbSupervisor {
    
    let writer: DbWriter
    
    func write(_ line: Line) async throws {
      do {
        try await writer.write(line)
      } catch {
        switch error {
            /// _Resume_ is just skiping error or _try?_ 🤔
          case LogProcessingError.dbBrokenConnectionException:
            break
          default:
            throw error
        }
      }
    }
    
    // TODO: Implement retry mechanism
    func retryWrite(_ line: Line) async throws {
      //      override def supervisorStrategy = OneForOneStrategy(
      //            maxNrOfRetries = 5,
      //            withinTimeRange = 60 seconds) {
      //              case _: DbBrokenConnectionException => Restart
      //            }
      //          val writer = context.actorOf(writerProps)
      //          def receive = {
      //            case m => writer forward (m)
      //          }
    }
    
    init(
      writer: DbWriter
    ) {
      self.writer = writer
    }
  }
}
