/// Is there a room for `Pool` vs. `Group` routing? 🤔
/// Seems like `Pool` is just create an actor for specific job,
/// where `Group` is—take existing actors.
actor PostalOfficeManager {
  
  func message() async {
    /// It's a pattern. Should be extracted into `Router` type as it's done in Akka.
    /// Example could be:
    /// ```
    ///  await Router
    ///     .roundRobin(poolSize: 4)
    ///     .execute {
    ///         messages
    ///           .filter({ $0.isGuaranteed })
    ///           .map(PostalOffice().message)
    ///     }
    /// ```
    ///  or something like this.
    let messages = Array(
      repeating: PostalOffice.Message.guaranteed("payslip"),
      count: 10
    )
    let poolSize = 4
    await withTaskGroup(of: Void.self) { group in
      for (index, message) in messages
        .filter({ $0.isGuaranteed })
        .enumerated() {
        if index > poolSize {
          await group.next()
        }
        group.addTask {
          await PostalOffice()
            .message(message)
        }
      }
      return await group
        .waitForAll()
    }
  }
}
