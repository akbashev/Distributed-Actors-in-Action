import DistributedCluster

distributed actor VIPGuest {
  
  private let name: String
  
  distributed func enterHotel() async {
    await self.actorSystem.receptionist.checkIn(self, with: .vipGuests)
  }
  
  distributed func getName() -> String { self.name }
  
  /// Actor system automatically checkouts once actor is terminated
  // func leaveHotel() async {}
  
  init(
    actorSystem: ActorSystem,
    name: String
  ) {
    self.actorSystem = actorSystem
    self.name = name
  }
}

extension DistributedReception.Key {
  static var vipGuests: DistributedReception.Key<VIPGuest> { "vip_guests" }
}
