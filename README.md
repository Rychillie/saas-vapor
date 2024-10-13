# SaaS Vapor Template

⚠️ **UNDER DEVELOPMENT** ⚠️

This project is a template for building Software as a Service (SaaS) applications using Vapor, a server-side Swift web framework. It provides a solid foundation for creating scalable and maintainable web applications with features commonly found in SaaS products.

## Features

- User authentication (sign up, sign in, password recovery)
- JWT-based authentication for protected routes
- PostgreSQL database integration
- Environment-based configuration
- Basic user profile management
- Multi-Tenant architecture with Organizations and Projects
- Role-based access control

## Development Status

This project is currently under active development. Here's a list of features and their current status:

- [x] User Authentication (Sign Up, Sign In)
- [x] JWT-based Authentication
- [x] Password Recovery Flow
- [x] Basic User Profile Management
- [x] Multi-Tenant Organization Structure
- [x] Project Creation within Organizations
- [ ] Role-Based Access Control (In Progress)
- [ ] Unit Tests (In Progress)
- [ ] Frontend with Leaf and Tailwind CSS (Planned)
- [ ] Email Integration with Resend (Planned)
- [ ] Image and File Upload (Planned)
- [ ] Billing Integration (Planned)
- [ ] API Rate Limiting (Planned)
- [ ] Webhooks (Planned)
- [ ] Audit Logs (Planned)

## Prerequisites

- Swift 5.2 or later
- Vapor 4
- PostgreSQL

## Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/saas-vapor-template.git
   cd saas-vapor-template
   ```

2. Install dependencies:
   ```
   swift package resolve
   ```

3. Set up your environment variables by creating a `.env` file in the project root:
   ```
   DB_HOSTNAME=localhost
   DB_PORT=5432
   DB_USERNAME=your_username
   DB_PASSWORD=your_password
   DB_DATABASE=your_database_name
   ```

4. Run database migrations:
   ```
   swift run Run migrate
   ```

## Running the Project

To run the project in development mode:

```
swift run Run serve --env development
```

The server will start on `http://localhost:8080`.

## Testing

To run the unit tests:

```
swift test
```

## API Endpoints

- `POST /auth/sign-up`: Create a new user account
- `POST /auth/sign-in`: Authenticate and receive a JWT token
- `GET /auth/profile`: Get the authenticated user's profile (protected route)
- `POST /auth/password/recover`: Request a password recovery
- `POST /auth/password/reset`: Reset password using a recovery token
- `POST /organizations`: Create a new organization
- `GET /organizations`: List user's organizations
- `POST /organizations/:id/projects`: Create a new project within an organization
- `GET /organizations/:id/projects`: List projects within an organization

For detailed API documentation, please refer to the [API Documentation](link-to-your-api-docs).

## Project Structure

```
.
├── Sources
│   └── App
│       ├── Controllers
│       ├── Models
│       ├── Migrations
│       ├── Middleware
│       ├── Services
│       ├── configure.swift
│       └── routes.swift
├── Tests
├── Resources
│   └── Views
├── Public
├── Package.swift
└── README.md
```

## Customization

This template provides a starting point for your SaaS application. You can customize and extend it by:

1. Adding new models and controllers
2. Implementing additional features specific to your SaaS product
3. Customizing the authentication flow
4. Adding more complex database relationships
5. Implementing custom business logic for multi-tenancy
6. Creating Leaf templates for the frontend
7. Styling your frontend with Tailwind CSS

## Deployment

For deployment instructions, please refer to the [Vapor documentation on deploying to production](https://docs.vapor.codes/4.0/deploy/digital-ocean/).

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Vapor](https://vapor.codes) - The web framework used
- [Swift](https://swift.org) - The programming language
- [Leaf](https://github.com/vapor/leaf) - Templating language for Vapor
- [Tailwind CSS](https://tailwindcss.com) - A utility-first CSS framework
- [Resend](https://resend.com) - Email API service

## Support

If you have any questions or need help with the template, please open an issue in the GitHub repository.
