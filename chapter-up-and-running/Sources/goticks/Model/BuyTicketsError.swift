import Vapor

enum BuyTicketsError: Content, Error {
  case notEnoughTickets
}
