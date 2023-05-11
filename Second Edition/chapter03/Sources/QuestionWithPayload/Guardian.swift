actor Guardian {

  private lazy var manager: Manager = Manager()
  
  func start() async {
    await self.manager.delegate(texts: ["text-a", "text-b", "text-c"])
  }
}
