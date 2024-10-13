import Vapor
import Fluent


struct CreateProject: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("projects")
            .id()
            .field("name", .string, .required)
            .field("description", .string, .required)
            .field("slug", .string, .required)
            .field("avatar_url", .string)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime)
            .field("organization_id", .uuid, .required, .references("organizations", "id", onDelete: .cascade))
            .field("owner_id", .uuid, .required, .references("users", "id"))
            .unique(on: "slug")
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("projects").delete()
    }
}
