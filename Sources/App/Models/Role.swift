import Vapor

enum Role: String, Codable {
  case ADMIN
  case MEMBER
  case BILLING
}
