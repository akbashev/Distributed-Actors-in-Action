import DistributedCluster

distributed actor PostalOffice: DistributedWorker {
  
  enum Message: Codable, Equatable {
    case standard(String)
    case tracked(String)
    case guaranteed(String)
    
    var isGuaranteed: Bool {
      switch self {
        case .guaranteed:
          return true
        default:
          return false
      }
    }
  }
  
  enum Result: Codable {
    case done
    case error(String)
  }
  
  distributed func submit(work: Message) async throws -> Result {
    try await Task.sleep(for: .seconds(Int.random(in: 0..<1)))
    return .done
  }
}

extension DistributedReception.Key {
  static var postalOffices: DistributedReception.Key<PostalOffice> { "postal_offices" }
}
