actor PostalOffice {
  enum Message {
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
  
  func message(_ message: Message) {
    /// do hard stuff
  }
}
