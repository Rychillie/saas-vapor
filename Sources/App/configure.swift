import Fluent
import FluentPostgresDriver
import JWT
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // Serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    // Register Leaf for Views
    app.views.use(.leaf)

    // Configuração do JWT: define a chave de assinatura sem o uso de 'kid'
    app.jwt.signers.use(.hs256(key: Environment.get("JWT_SECRET") ?? "secret"))
    
    // Configuração do banco de dados
    let hostname = getEnvValue("DB_HOSTNAME", defaultValue: "localhost")
    let port = Environment.get("DB_PORT").flatMap(Int.init) ?? 5432
    let username = getEnvValue("DB_USERNAME", defaultValue: "postgres")
    let password = getEnvValue("DB_PASSWORD", defaultValue: "password")
    let database = getEnvValue("DB_DATABASE", defaultValue: "vapor_database")

    let databaseConfig = SQLPostgresConfiguration(
        hostname: hostname,
        port: port,
        username: username,
        password: password,
        database: database,
        tls: .disable
    )

    app.databases.use(.postgres(configuration: databaseConfig), as: .psql)
    
    // Register migrations
    app.migrations.add(CreateUser())
    app.migrations.add(CreateOrganization())
    app.migrations.add(CreateToken())
    app.migrations.add(CreateAccount())
    app.migrations.add(CreateMember())
    app.migrations.add(CreateInvite())
    app.migrations.add(CreateProject())
    
    // Register routes
    try routes(app)
}

// Helper function to get values ​​from the environment
func getEnvValue(_ key: String, defaultValue: String) -> String {
    Environment.get(key) ?? defaultValue
}
