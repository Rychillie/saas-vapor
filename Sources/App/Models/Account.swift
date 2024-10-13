import Vapor
import Fluent

final class Account: Model, Content {
    static let schema = "accounts"
    
    @ID(key: .id)
    var id: UUID?

    @Enum(key: "provider")
    var provider: AccountProvider

    @Field(key: "provider_account_id")
    var providerAccountId: String

    @Parent(key: "user_id")
    var user: User

    init() { }

    init(id: UUID? = nil, provider: AccountProvider, providerAccountId: String, userID: UUID) {
        self.id = id
        self.provider = provider
        self.providerAccountId = providerAccountId
        self.$user.id = userID
    }
}

enum AccountProvider: String, Codable {
    case GITHUB
}
