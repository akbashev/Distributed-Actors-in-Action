actor Guardian {

  private lazy var manager: Manager = Manager()
  
  func start(texts: [String]) async {
    await self.manager.delegate(texts: texts)
  }
}
