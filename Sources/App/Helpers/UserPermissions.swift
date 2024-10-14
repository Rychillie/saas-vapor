import Fluent
import Vapor

struct UserPermissions {
  let userID: UUID
  let role: Role

  func cannot(_ action: String, _ resource: String) -> Bool {
    switch (action, resource) {
    case ("get", "User"):
      return false  // Allow viewing members by default
    case ("update", "User"), ("delete", "User"):
      return role != .ADMIN
    default:
      return true  // Deny by default
    }
  }
}

extension Request {
  func getUserPermissions(for organizationID: UUID) async throws -> UserPermissions {
    guard let user = auth.get(User.self) else {
      throw Abort(.unauthorized)
    }

    let member = try await Member.query(on: db)
      .filter(\.$organization.$id == organizationID)
      .filter(\.$user.$id == user.requireID())
      .first()

    // If the user is not a member, assume they have no permissions
    let role = member?.role ?? .MEMBER

    return UserPermissions(userID: try user.requireID(), role: role)
  }
}
