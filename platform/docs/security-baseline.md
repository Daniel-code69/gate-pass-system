# Phase 1 Security Baseline

- TLS in production.
- Secrets only in server-side secret storage/environment configuration.
- No PostgreSQL credentials in Flutter.
- No Firebase service-account private keys in Flutter.
- Server-side validation for every request.
- Parameterized ORM queries only.
- Rate limits on authentication and other abuse-prone endpoints.
- Generic authentication error messages where appropriate.
- Audit sensitive mutations and privileged reads/exports.
- Minimize personal data returned to each role.
- QR codes contain opaque identifiers/tokens, not unnecessary personal data.
- Database backups must be encrypted and access-controlled.
