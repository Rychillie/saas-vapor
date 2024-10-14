import Vapor
import Fluent

struct AuthMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        // Add the getCurrentUserId function to the Request
        request.getCurrentUserId = {
            guard let payload = try? request.jwt.verify(as: TokenPayload.self) else {
                throw Abort(.unauthorized, reason: "Invalid token")
            }
            return payload.sub
        }

        // Add the get User Membership on Request function
        request.getUserMembership = { slug in
            let userId = try await request.getCurrentUserId()
            
            guard let member = try await Member.query(on: request.db)
                .join(Organization.self, on: \Member.$organization.$id == \Organization.$id)
                .filter(Organization.self, \.$slug == slug)
                .filter(\.$user.$id == userId)
                .with(\.$organization)
                .first() else {
                throw Abort(.unauthorized, reason: "You're not a member of this organization.")
            }
            
            let organization = try await member.$organization.get(on: request.db)
            return (organization: organization, membership: member)
        }

        return try await next.respond(to: request)
    }
}

// Extensions to add new functions to Request
extension Request {
    var getCurrentUserId: () async throws -> UUID {
        get { storage[CurrentUserIdKey.self] ?? { throw Abort(.internalServerError, reason: "getCurrentUserId not implemented") } }
        set { storage[CurrentUserIdKey.self] = newValue }
    }

    var getUserMembership: (String) async throws -> (organization: Organization, membership: Member) {
        get { storage[GetUserMembershipKey.self] ?? { _ in throw Abort(.internalServerError, reason: "getUserMembership not implemented") } }
        set { storage[GetUserMembershipKey.self] = newValue }
    }
}

private struct CurrentUserIdKey: StorageKey {
    typealias Value = () async throws -> UUID
}

private struct GetUserMembershipKey: StorageKey {
    typealias Value = (String) async throws -> (organization: Organization, membership: Member)
}
