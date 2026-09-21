# Phase 1 API Contract

## Error envelope
All API errors should use:

{
  "error": {
    "code": "MACHINE_READABLE_CODE",
    "message": "Human-readable message",
    "requestId": "request-id"
  }
}

Never return database errors, stack traces, secrets, or authorization internals to clients.

## Authentication
- Access tokens are short-lived.
- Refresh/session credentials are revocable.
- Passwords, if password authentication is selected, are stored only as strong password hashes.
- The mobile client never determines its own role.

## Authorization
Every protected endpoint evaluates:
1. authentication
2. role
3. resource scope
4. action
5. academic/institutional scope where applicable

## Audit
Sensitive actions emit immutable audit events with actor, action, target, timestamp, request ID and outcome.
