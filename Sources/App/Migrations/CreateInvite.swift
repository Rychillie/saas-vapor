import Vapor
import Fluent

struct CreateInvite: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("invites")
            .id()
            .field("email", .string, .required)
            .field("role", .string, .required)
            .field("created_at", .datetime, .required)
            .field("author_id", .uuid, .references("users", "id", onDelete: .setNull))
            .field("organization_id", .uuid, .required, .references("organizations", "id", onDelete: .cascade))
            .unique(on: "email", "organization_id")
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("invites").delete()
    }
}
