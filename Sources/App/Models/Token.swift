import Vapor
import Fluent

final class Token: Model, Content {
    static let schema = "tokens"
    
    @ID(key: .id)
    var id: UUID?

    @Enum(key: "type")
    var type: TokenType

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Parent(key: "user_id")
    var user: User

    init() { }

    init(id: UUID? = nil, type: TokenType, userID: UUID) {
        self.id = id
        self.type = type
        self.$user.id = userID
    }
}

enum TokenType: String, Codable {
    case PASSWORD_RECOVER
}
