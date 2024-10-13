import Vapor
import Fluent

struct CreateAccount: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("accounts")
            .id()
            .field("provider", .string, .required)
            .field("provider_account_id", .string, .required)
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .unique(on: "provider_account_id")
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("accounts").delete()
    }
}
