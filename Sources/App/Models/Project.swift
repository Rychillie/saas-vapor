import Vapor
import Fluent


final class Project: Model, Content {
    static let schema = "projects"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "description")
    var description: String

    @Field(key: "slug")
    var slug: String

    @Field(key: "avatar_url")
    var avatarUrl: String?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Parent(key: "organization_id")
    var organization: Organization

    @Parent(key: "owner_id")
    var owner: User

    init() { }

    init(id: UUID? = nil, name: String, description: String, slug: String, organizationID: UUID, ownerID: UUID, avatarUrl: String?) {
        self.id = id
        self.name = name
        self.description = description
        self.slug = slug
        self.$organization.id = organizationID
        self.$owner.id = ownerID
        self.avatarUrl = avatarUrl
    }
}
