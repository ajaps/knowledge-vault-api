# Knowledge Vault API

# README
A RESTful API for managing knowledge collections with owner and read-only shared access keys.

This README would normally document whatever steps are necessary to get the
application up and running.

## Tech
  - Rails 8, Postgres
  - Auth: API Key (`X-API-Key`)
  - AuthZ: Pundit
  - Tests: RSpec

## API Key System
  Two Types of API Keys

  Owner API Key (owner_api_key)

  Generated automatically when user is created
  Full CRUD permissions on user's own vaults and documents
  Cannot be shared safely (grants full access)
  Can regenerate if compromised


  Shared API Keys (shared_api_keys)

  Created by owner for sharing
  Read-only access to all owner's vaults and documents
  Can view and download, but cannot create/update/delete
  Can be named (e.g., "Key for Bob", "Team Key")
  Can be deactivated without affecting owner key
  Tracks last usage time

### All requests require an API key in the Authorization header except the user-create route:
  `Authorization: Bearer <api_key>`

## Setup
  - `git clone <repo>`
  - `cd knowledge_vault`
  - `cp .env.example .env   # DB creds, SECRET_KEY_BASE`
  - `bundle install`
  - Run `rails db:setup`
  - `bin/rails db:create db:migrate db:seed`
  - `bin/rails s`
  - `rails s` - to start the server


## Routes
  POST /api/v1/users - Signup
  GET /api/v1/users/me - Get current user info
  POST /api/v1/users/regenerate_owner_api_key - Regenerate Owner API key
  POST /api/v1/users/shared_keys - create shared keys
  GET /api/v1/users/shared_keys - List shared keys
  DELETE /api/v1/users/shared_keys/1 - Deactivate shared key

  POST /api/v1/vaults - Create Vaults
  GET /api/v1/vaults - List Vaults
  PUT /api/v1/vaults/1 - Update Vaults


  POST /api/v1/vaults/1/documents - Create Documents
  GET /api/v1/vaults/1/documents - List Documents
  PUT /api/v1/vaults/1/documents/1 - Update Documet
  DELETE /api/v1/vaults/1/documents/1 - Delete Document

 ## Test
  - To run tests `rspec`

## Design Decisions
  Why Two Key Types?
  Original Problem: If users share a single API key, the recipient has full access (can delete everything).
  Solution: Separate owner and shared keys with different permission levels enforced at the controller level.
  
  Key Features:

  1. Automatic Detection: System automatically identifies key type on every request
  2. Permission Enforcement: require_owner_key! helper blocks unauthorized actions
  3. Audit Trail: Shared keys track last_used_at for monitoring
  4. Revocable: Shared keys can be deactivated without affecting owner's access
  5. Named Keys: Optional naming helps track who has which key

## Notes & Trade-offs

    API key over JWT for simplicity.

    Pundit for role checks.

    Search via ILIKE; upgrade to trigram later.

## Future

  1. Vault-specific shared keys (share only certain vaults)
  2. Expiring shared keys (auto-deactivate after X days)
  3. Permission scopes (read-only vs. read-write vs. admin)
  4. API key usage analytics dashboard
  5. Webhook notifications when shared keys are used
  6. IP whitelisting for shared keys
  7. Audit logs.

## Production file storage plan

  Bucket setup

  Create kv-prod-docs in S3

  Turn on versioning and block public access

  Use key format like vaults/{vault_id}/docs/{doc_id}/{uuid}.{ext}

  Add lifecycle rules to archive old versions to Glacier or delete after a year

  Permissions

  Give the app an IAM role with only s3:GetObject, s3:PutObject, s3:DeleteObject on that bucket

  Encrypt files with KMS key (alias/kv-docs)

  Restrict access to the app VPC via an S3 endpoint

  Upload process

  User requests upload from backend

  Backend checks vault role (owner/editor only)

  Backend returns presigned POST URL and fields

  User uploads directly to S3

  Backend saves file info in DB: path, size, checksum, content type

  Database tracking

  Add columns to documents: file_key, content_type, size_bytes, checksum, version_id, meta (jsonb)

  On finalize, use head_object to fetch size, version, checksum

  Security & roles

  Files stay private in S3

  Encryption with KMS

  Only owner/editor can upload or delete

  Readers get short-lived presigned download links

  Every action logged with api_key, user_id, vault_id, doc_id

  Download

  Backend verifies access, then generates a 5-minute presigned GET URL

  Integrity

  Check file size and type before signing

  Optional malware scan triggered by S3 event

  Monitoring

  CloudTrail logs for bucket activity

  Alerts on unusual reads/writes

  Deployment

  Manage S3, KMS, IAM, lifecycle, and logging with Terraform