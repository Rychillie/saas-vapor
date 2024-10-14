import Fluent
import Vapor

final class Member: Model, Content {
    static let schema = "members"

    @ID(key: .id)
    var id: UUID?

    @Enum(key: "role")
    var role: Role

    @Parent(key: "organization_id")
    var organization: Organization

    @Parent(key: "user_id")
    var user: User

    init() {}

    init(id: UUID? = nil, role: Role = .MEMBER, organizationID: UUID, userID: UUID) {
        self.id = id
        self.role = role
        self.$organization.id = organizationID
        self.$user.id = userID
    }
}
