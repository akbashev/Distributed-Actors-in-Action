# GoTicks.com

This is a port of second chapter example from _Akka in Action_ book [Up and Running](https://github.com/RayRoestenburg/akka-in-action/tree/master/chapter-up-and-running).

For now skipped the deployment part, will return back after implementing next chapters (see TODO).

## Notes on implementation

### Dependencies

* [Vapor](https://vapor.codes) for quick Rest API implementation.

### Similarities

As actor model is universal, and Scala and Swift are similar in lot's of ways, porting logic to Swift Actors was straightforward.
So you'll have same _BoxOffice_ and _TicketSeller_ actors, _RestApi_ implementation and _GoTicks_ class (or better say _struct_ 🙃) with configuration that runs the app (_@main_).

### Differences

With differences it becomes a bit more interesting:

* Actors (including Distributed) are part of Swift language itself. In practise it means that you don't have a lot of boilerplate, like having _context_ and surrounding helping types. In case of Swift actors _context_ means just _do everything inside actor as usual without thinking about system_ and good example for that will be _BoxOffice_. It creates and saves actors in simple dictionary, where you can then quickly lookup seller by event name.
* 🔝 Although we don't use _distributed_ actors in that example, there is one of interesting differences of actor's implementation in Swift vs. Akka: in Swift you can make children _NOT_ distributed, just normal actor. With Akka every actor can fail randomly, which means you need to build defensive mechanisms arround. With Swift you have a choise of making actors distributed in whole system, or spawn for one particalur parent, which will only fail with that node (like only for that server in the example). We'll be exploring this behaviour in next chapters.
* Swift actors build on top of async/await concurrency tools, you don't have boileplate of Future and other types.
* Distributed actors use Swift's _Codable_ for serialising and passing data (Vapor's _Content_ conforms to _Codable_), so you don't need to think about defining json formatts (and _EventMarshalling_ been removed).
* Actors in Swift can't terminate itself like _PoisonPill_ in Akka, due to memory managment ([ARC](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/automaticreferencecounting/)). So parent node should just remove a refernce to a child to cancel an event.
* Changed responses like _EventResponse_ in favour of throwing different errors, like _CreateEventError_. Makes code easier to read.

## TODO

* Add deployment part
* Add tests
* Check on Linux
* Add documentation ([DocC](https://www.swift.org/documentation/docc/))
* Remove returning Optional types and instead throw specific errors?
