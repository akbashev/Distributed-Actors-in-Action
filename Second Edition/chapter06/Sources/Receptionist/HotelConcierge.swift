import DistributedCluster

distributed actor HotelConcierge {
    
  var listingTask: Task<Void, Never>?
  
  distributed func listing() async {
    guard listingTask == nil else {
      actorSystem.log.info("Already looking for workers")
      return
    }
    
    listingTask = Task {
      for await guest in await actorSystem.receptionist.listing(of: .vipGuests) {
        let name = (try? await guest.getName()) ?? ""
        actorSystem.log.info("Guest \(name) is in.")
      }
    }
  }
  
  /// There are GuestSearch and GuestFinder examples in Akka repo, which so far don't get why you need them 🤔
  distributed func findGuest(with name: String) async -> VIPGuest? {
    await actorSystem
      .receptionist
      .listing(of: .vipGuests)
      .first(where: { (try? await $0.getName()) == name })
  }
  
  deinit {
    listingTask?.cancel()
  }
}
