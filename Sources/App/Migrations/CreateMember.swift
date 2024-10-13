import Vapor
import Fluent

struct CreateMember: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("members")
            .id()
            .field("role", .string, .required)
            .field("organization_id", .uuid, .required, .references("organizations", "id", onDelete: .cascade))
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .unique(on: "organization_id", "user_id")
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("members").delete()
    }
}
