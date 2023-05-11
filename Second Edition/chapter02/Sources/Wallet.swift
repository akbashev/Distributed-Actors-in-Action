actor Wallet {
  
  private var state: State = .activated(0)
  
  func increase(_ amount: Int) {
    switch self.state {
      case .activated(let total):
        let current = total + amount
        print("Increasing to \(current)")
        self.state = .activated(current)
      case .deactivated(_):
        print("Wallet is deactivated. Can't increase.")
    }
  }
  
  private func activate() {
    print("Activating.")
    self.state = .activated(self.state.total)
  }
  
  func deactivate(_ seconds: Int) async throws {
    switch self.state {
      case .deactivated(_):
        print("Wallet is deactivated. Can't be deactivated again.")
      case .activated(let total):
        self.state = .deactivated(total)
        try await Task.sleep(for: .seconds(seconds))
        self.activate()
    }
  }
}

extension Wallet {
  enum State {
    case activated(Int)
    case deactivated(Int)
    
    var total: Int {
      switch self {
        case .activated(let amount),
            .deactivated(let amount):
          return amount
      }
    }
  }
}
