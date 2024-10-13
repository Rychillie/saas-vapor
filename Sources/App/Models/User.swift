import Fluent
import Vapor

final class User: Model, Content, Authenticatable {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String?

    @Field(key: "email")
    var email: String

    @Field(key: "password_hash")
    var passwordHash: String?

    @Field(key: "avatar_url")
    var avatarUrl: String?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    // Relacionamentos
    @Children(for: \.$user)
    var tokens: [Token]

    @Children(for: \.$user)
    var accounts: [Account]

    @Children(for: \.$author)
    var invites: [Invite]

    @Children(for: \.$owner)
    var ownsOrganizations: [Organization]

    @Children(for: \.$owner)
    var ownsProjects: [Project]

    @Siblings(through: Member.self, from: \.$user, to: \.$organization)
    var memberOnOrganizations: [Organization]

    init() {}

    init(id: UUID? = nil, name: String?, email: String, passwordHash: String?, avatarUrl: String?) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
        self.avatarUrl = avatarUrl
    }
}
