import Vapor
import Fluent

struct CreateOrganization: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("organizations")
            .id()
            .field("name", .string, .required)
            .field("slug", .string, .required)
            .field("domain", .string)
            .field("should_attach_users_by_domain", .bool, .required, .sql(.default(false)))
            .field("avatar_url", .string)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime)
            .field("owner_id", .uuid, .required, .references("users", "id"))
            .unique(on: "slug")
            .unique(on: "domain")
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("organizations").delete()
    }
}
