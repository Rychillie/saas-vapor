import Fluent
import Vapor

struct MemberController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let members = routes.grouped("organizations", ":organizationID", "members")
    let protectedMembers = members.grouped(JWTAuthenticator())
    protectedMembers.get(use: index)
    protectedMembers.delete(":memberID", use: remove)
    protectedMembers.put(":memberID", use: update)
  }

  func index(req: Request) async throws -> [MemberResponse] {
    guard let organizationID = req.parameters.get("organizationID", as: UUID.self) else {
      throw Abort(.badRequest, reason: "Invalid organization ID")
    }

    guard let organization = try await Organization.find(organizationID, on: req.db) else {
      throw Abort(.notFound, reason: "Organization not found")
    }

    let permissions = try await req.getUserPermissions(for: organization.requireID())
    if permissions.cannot("get", "User") {
      throw Abort(.forbidden, reason: "You're not allowed to see organization members.")
    }

    let members = try await Member.query(on: req.db)
      .with(\.$user)
      .filter(\.$organization.$id == organization.id!)
      .all()

    // Include the owner if not already in the members list
    var memberResponses = members.map { member in
      MemberResponse(
        id: member.id!,
        userId: member.user.id!,
        role: member.role,
        name: member.user.name,
        email: member.user.email,
        avatarUrl: member.user.avatarUrl
      )
    }

    // Check if owner is not in the list and add them
    if !memberResponses.contains(where: { $0.userId == organization.$owner.id }) {
      let owner = try await organization.$owner.get(on: req.db)
      memberResponses.append(
        MemberResponse(
          id: UUID(),  // Generate a new UUID for consistency
          userId: owner.id!,
          role: .ADMIN,
          name: owner.name,
          email: owner.email,
          avatarUrl: owner.avatarUrl
        )
      )
    }

    return memberResponses
  }

  func remove(req: Request) async throws -> HTTPStatus {
    guard let organization = try await Organization.find(req.parameters.get("organizationID"), on: req.db) else {
      throw Abort(.notFound)
    }

    let permissions = try await req.getUserPermissions(for: organization.requireID())
    guard !permissions.cannot("delete", "User") else {
      throw Abort(.forbidden, reason: "You're not allowed to remove this member from organization.")
    }

    guard let member = try await Member.find(req.parameters.get("memberID"), on: req.db) else {
      throw Abort(.notFound)
    }

    if member.$organization.id != organization.id {
      throw Abort(.notFound)
    }

    try await member.delete(on: req.db)
    return .noContent
  }

  func update(req: Request) async throws -> HTTPStatus {
    guard let organization = try await Organization.find(req.parameters.get("organizationID"), on: req.db) else {
      throw Abort(.notFound)
    }

    let permissions = try await req.getUserPermissions(for: organization.requireID())
    guard !permissions.cannot("update", "User") else {
      throw Abort(.forbidden, reason: "You're not allowed to update this member.")
    }

    guard let member = try await Member.find(req.parameters.get("memberID"), on: req.db) else {
      throw Abort(.notFound)
    }

    if member.$organization.id != organization.id {
      throw Abort(.notFound)
    }

    let input = try req.content.decode(UpdateMemberInput.self)
    member.role = input.role
    try await member.save(on: req.db)

    return .noContent
  }
}

struct MemberResponse: Content {
  let id: UUID
  let userId: UUID
  let role: Role
  let name: String?
  let email: String
  let avatarUrl: String?
}

struct UpdateMemberInput: Content {
  let role: Role
}
