actor Worker {
  func parse(text: String) async throws {
    try await Task.sleep(for: .seconds(Int.random(in: 2...4)))
    /// Think a better way is not printing here, cause you'll anyway land in
    /// situtation where actor will still pring even after cancelling a task in manager,
    /// but rather returning a parsed text to a manager, who prints everything.
    print("\(self): Done.")
  }
}
