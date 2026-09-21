# College Platform — Phase 1 Foundation

This branch is the Phase 1 foundation for the Gour Mahavidyalaya college platform.

## Architecture
Flutter client → NestJS API → PostgreSQL/Prisma

Firebase Cloud Messaging is reserved for push delivery. The backend remains the authority for authentication, authorization, business rules, and audit logging.

## Safety
The legacy Gate Pass implementation remains intact. This branch adds only the foundation documents and API contract skeleton.

## Next implementation
- NestJS application bootstrap
- PostgreSQL/Prisma schema
- Authentication/session module
- RBAC + object-scope authorization
- audit log
- health checks
- automated tests and CI
