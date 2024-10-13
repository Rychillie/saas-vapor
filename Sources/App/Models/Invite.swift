import Vapor
import Fluent

final class Invite: Model, Content {
    static let schema = "invites"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "email")
    var email: String

    @Enum(key: "role")
    var role: Role

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @OptionalParent(key: "author_id")
    var author: User?

    @Parent(key: "organization_id")
    var organization: Organization

    init() { }

    init(id: UUID? = nil, email: String, role: Role, organizationID: UUID, authorID: UUID? = nil) {
        self.id = id
        self.email = email
        self.role = role
        self.$organization.id = organizationID
        self.$author.id = authorID
    }
}

enum Role: String, Codable {
    case ADMIN
    case MEMBER
    case BILLING
}
