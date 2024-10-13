import Vapor
import Fluent

final class Organization: Model, Content {
    static let schema = "organizations"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "slug")
    var slug: String

    @Field(key: "domain")
    var domain: String?

    @Field(key: "should_attach_users_by_domain")
    var shouldAttachUsersByDomain: Bool

    @Field(key: "avatar_url")
    var avatarUrl: String?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Parent(key: "owner_id")
    var owner: User

    @Children(for: \.$organization)
    var invites: [Invite]

    @Children(for: \.$organization)
    var members: [Member]

    @Children(for: \.$organization)
    var projects: [Project]

    init() { }

    init(id: UUID? = nil, name: String, slug: String, domain: String?, shouldAttachUsersByDomain: Bool, ownerID: UUID, avatarUrl: String?) {
        self.id = id
        self.name = name
        self.slug = slug
        self.domain = domain
        self.shouldAttachUsersByDomain = shouldAttachUsersByDomain
        self.$owner.id = ownerID
        self.avatarUrl = avatarUrl
    }
}
