import Fluent
import JWT
import Vapor

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let authRoutes = routes.grouped("auth")

        // Authentication routes
        authRoutes.post("sign-up", use: signUp)
        authRoutes.post("sign-in", use: signIn)

        // Protected route to get the profile
        let protectedRoutes = authRoutes.grouped(JWTAuthenticator())  // Rotas que requerem autenticação JWT
        protectedRoutes.get("profile", use: getProfile)

        // Password recovery routes
        authRoutes.post("password/recover", use: requestPasswordRecover)
        authRoutes.post("password/reset", use: resetPassword)
    }

    // Function for Sign Up
    func signUp(req: Request) async throws -> HTTPStatus {
        let signUpDTO = try req.content.decode(SignUpDTO.self)

        // Check if the email is already in use
        let existingUser = try await User.query(on: req.db).filter(\.$email == signUpDTO.email)
            .first()
        if existingUser != nil {
            throw Abort(.badRequest, reason: "User with this email already exists.")
        }

        // Hash password using BCrypt
        let hashedPassword = try Bcrypt.hash(signUpDTO.password)

        // Check if there is an organization for this domain
        let emailDomain = String(signUpDTO.email.split(separator: "@").last ?? "")
        let organization = try await Organization.query(on: req.db)
            .filter(\.$domain == emailDomain)
            .filter(\.$shouldAttachUsersByDomain == true)
            .first()

        // Create the new user
        let user = User(
            name: signUpDTO.name,
            email: signUpDTO.email,
            passwordHash: hashedPassword,
            avatarUrl: nil
        )
        try await user.save(on: req.db)

        // If there is an organization, add the user to it
        if let organization = organization {
            let member = Member(
                role: .MEMBER, organizationID: try organization.requireID(),
                userID: try user.requireID()
            )
            try await member.save(on: req.db)
        }

        return .created
    }

    // Function for Sign In
    func signIn(req: Request) async throws -> Response {
        let signInDTO = try req.content.decode(SignInDTO.self)

        // Search the user in the database by email
        guard let user = try await User.query(on: req.db).filter(\.$email == signInDTO.email).first() else {
            throw Abort(.badRequest, reason: "Invalid credentials.")
        }

        // Check if the password hash is valid
        guard let passwordHash = user.passwordHash else {
            throw Abort(.badRequest, reason: "User does not have a password, use social login.")
        }

        let isPasswordValid = try Bcrypt.verify(signInDTO.password, created: passwordHash)
        if !isPasswordValid {
            throw Abort(.badRequest, reason: "Invalid credentials.")
        }

        // Create the JWT payload
        let expiration = ExpirationClaim(value: Date().addingTimeInterval(60 * 60 * 24 * 7))  // 7 dias
        let payload = TokenPayload(sub: try user.requireID(), exp: expiration)

        // Sign the JWT token
        let token = try req.jwt.sign(payload)

        // Return token as response
        return Response(status: .ok, body: .init(string: "{\"token\": \"\(token)\"}"))
    }

    // Function to obtain the authenticated user profile
    func getProfile(req: Request) async throws -> User.Public {
        guard let user = req.auth.get(User.self) else {
            throw Abort(.unauthorized)
        }
        return user.asPublic()
    }

    // Function to request password recovery
    func requestPasswordRecover(req: Request) async throws -> HTTPStatus {
        let emailDTO = try req.content.decode(EmailDTO.self)

        // Search user by email
        guard let user = try await User.query(on: req.db).filter(\.$email == emailDTO.email).first() else {
            return .created  // Returns 201 even if the user does not exist to avoid exposure
        }

        // Create a password recovery token
        let token = Token(type: .PASSWORD_RECOVER, userID: try user.requireID())
        try await token.save(on: req.db)

        // TODO: Email sending simulation (in production, send the real email)
        print("Token de recuperação de senha: \(token.id!)")

        return .created
    }

    // Function to reset password
    func resetPassword(req: Request) async throws -> HTTPStatus {
        let resetDTO = try req.content.decode(ResetPasswordDTO.self)

        // Fetch password recovery token
        guard let token = try await Token.query(on: req.db)
            .filter(\.$id == resetDTO.code)
            .filter(\.$type == .PASSWORD_RECOVER)
            .first()
        else {
            throw Abort(.unauthorized)
        }

        // Hash the new password
        let hashedPassword = try Bcrypt.hash(resetDTO.password)

        // Atualiza a senha do usuário e apaga o token
        try await req.db.transaction { db in
            try await User.query(on: db).filter(\.$id == token.$user.id).set(
                \.$passwordHash, to: hashedPassword
            ).update()
            try await token.delete(on: db)
        }

        return .noContent
    }
}

// JWT Configuration
struct TokenPayload: JWTPayload {
    var sub: UUID
    var exp: ExpirationClaim

    func verify(using signer: JWTSigner) throws {
        try self.exp.verifyNotExpired()
    }
}

// DTOs
struct SignUpDTO: Content {
    let name: String
    let email: String
    let password: String
}

struct SignInDTO: Content {
    let email: String
    let password: String
}

struct EmailDTO: Content {
    let email: String
}

struct ResetPasswordDTO: Content {
    let code: UUID
    let password: String
}

// User Public DTO to return secure information
extension User {
    struct Public: Content {
        let id: UUID
        let name: String?
        let email: String
        let avatarUrl: String?
    }

    func asPublic() -> Public {
        return Public(id: self.id!, name: self.name, email: self.email, avatarUrl: self.avatarUrl)
    }
}

struct JWTAuthenticator: AsyncBearerAuthenticator {
    typealias User = App.User

    func authenticate(bearer: BearerAuthorization, for request: Request) async throws {
        guard let payload = try? request.jwt.verify(as: TokenPayload.self) else {
            throw Abort(.unauthorized)
        }

        guard let user = try await User.find(payload.sub, on: request.db) else {
            throw Abort(.unauthorized)
        }

        request.auth.login(user)
    }
}
