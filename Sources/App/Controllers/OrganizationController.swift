import Fluent
import Vapor

struct OrganizationController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let organizations = routes.grouped("organizations")
        let protectedOrganizations = organizations.grouped(JWTAuthenticator())
        protectedOrganizations.post(use: create)
        protectedOrganizations.get(use: index)
        protectedOrganizations.group(":organizationID") { organization in
            organization.get(use: show)
            organization.put(use: update)
            organization.delete(use: delete)
        }
    }
    
    func create(req: Request) async throws -> Organization {
        let input = try req.content.decode(CreateOrganizationInput.self)
        let user = try req.auth.require(User.self)
        let organization = try Organization(
            name: input.name,
            slug: input.name.createSlug(),
            domain: input.domain,
            shouldAttachUsersByDomain: input.shouldAttachUsersByDomain,
            ownerID: user.requireID(),
            avatarUrl: nil
        )
        try await validateOrganization(organization, on: req.db)
        try await organization.save(on: req.db)
        
        // Add the owner as a member with ADMIN role
        let member = try Member(role: .ADMIN, organizationID: organization.requireID(), userID: user.requireID())
        try await member.save(on: req.db)
        
        return organization
    }
    
    func index(req: Request) async throws -> [Organization] {
        try await Organization.query(on: req.db).all()
    }
    
    func show(req: Request) async throws -> Organization {
        guard let organization = try await Organization.find(req.parameters.get("organizationID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return organization
    }
    
    func update(req: Request) async throws -> Organization {
        guard let organization = try await Organization.find(req.parameters.get("organizationID"), on: req.db) else {
            throw Abort(.notFound)
        }
        let input = try req.content.decode(UpdateOrganizationInput.self)
        organization.name = input.name
        organization.domain = input.domain
        organization.shouldAttachUsersByDomain = input.shouldAttachUsersByDomain
        try await validateOrganization(organization, on: req.db)
        try await organization.save(on: req.db)
        return organization
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        guard let organization = try await Organization.find(req.parameters.get("organizationID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await organization.delete(on: req.db)
        return .noContent
    }
    
    private func validateOrganization(_ organization: Organization, on db: Database) async throws {
        if let domain = organization.domain {
            if let organizationID = organization.id {
                if try await Organization.query(on: db).filter(\.$domain == domain).filter(\.$id != organizationID).first() != nil {
                    throw Abort(.badRequest, reason: "Another organization with the same domain already exists.")
                }
            } else {
                if try await Organization.query(on: db).filter(\.$domain == domain).first() != nil {
                    throw Abort(.badRequest, reason: "Another organization with the same domain already exists.")
                }
            }
        }
    }
}

struct CreateOrganizationInput: Content {
    let name: String
    let domain: String?
    let shouldAttachUsersByDomain: Bool
}

struct UpdateOrganizationInput: Content {
    let name: String
    let domain: String?
    let shouldAttachUsersByDomain: Bool
}
