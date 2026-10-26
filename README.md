# Enterprise AI Knowledge Platform — Multi-Tenant RAG SaaS

A secure, multi-tenant enterprise knowledge platform that enables organizations to upload private documents, search organizational knowledge, and ask questions using Retrieval-Augmented Generation (RAG). Answers are grounded in retrieved document passages and include source citations wherever available.

> **Project status:** In development  
> **Primary focus:** Enterprise RAG, multi-tenancy, backend engineering, AI integration, and production-oriented system design.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Objectives](#2-objectives)
3. [Key Features](#3-key-features)
4. [Technology Stack](#4-technology-stack)
5. [System Architecture](#5-system-architecture)
6. [User Roles and Permissions](#6-user-roles-and-permissions)
7. [Project Structure](#7-project-structure)
8. [Database Design](#8-database-design)
9. [Core Workflows](#9-core-workflows)
10. [API Documentation](#10-api-documentation)
11. [RAG Pipeline](#11-rag-pipeline)
12. [Security and Multi-Tenant Isolation](#12-security-and-multi-tenant-isolation)
13. [Getting Started](#13-getting-started)
14. [Environment Configuration](#14-environment-configuration)
15. [Development Roadmap](#15-development-roadmap)
16. [Testing Strategy](#16-testing-strategy)
17. [Observability and Reliability](#17-observability-and-reliability)
18. [Evaluation Metrics](#18-evaluation-metrics)
19. [Deployment](#19-deployment)
20. [Acceptance Criteria](#20-acceptance-criteria)
21. [Future Enhancements](#21-future-enhancements)
22. [Contributing](#22-contributing)
23. [License](#23-license)

---

## 1. Project Overview

Enterprise AI Knowledge Platform is a SaaS application designed to help organizations interact with their internal knowledge using AI.

Traditional document management systems allow users to store and retrieve files, but finding precise answers across large collections of documents can be difficult. This platform combines semantic search, keyword search, and large language models (LLMs) to make organizational knowledge more accessible.

Users can upload documents to a knowledge base, wait for asynchronous processing, and ask natural-language questions. The system retrieves relevant passages, generates a context-grounded answer, and provides citations to the supporting sources.

The platform is designed around **multi-tenancy**, meaning multiple organizations can use the same application and infrastructure while their data remains logically isolated and access-controlled.

### Example use case

Consider two organizations using the same platform:

- **Organization A:** Stores internal HR policies, employee handbooks, and compliance documents.
- **Organization B:** Stores technical documentation, product specifications, and engineering procedures.

An authorized member of Organization A can ask:

> What is the annual leave policy for employees?

The platform retrieves relevant passages from Organization A's authorized documents and generates an answer with source references.

A member of Organization B must not be able to retrieve Organization A's documents, chunks, conversations, or search results, even if they know a document UUID or submit another organization's ID.

### Core design principles

- Tenant isolation by default.
- Authorization before retrieval and generation.
- Evidence-based answers with source citations.
- Asynchronous and retryable document processing.
- Clear separation of business logic and AI orchestration.
- Provider-independent embedding and LLM integration.
- Observable, testable, and maintainable services.

---

## 2. Objectives

The main objective is to build a production-oriented enterprise knowledge platform demonstrating the following engineering capabilities:

1. Design a secure multi-tenant SaaS architecture.
2. Implement REST APIs using Java and Spring Boot.
3. Model organizations, users, memberships, knowledge bases, documents, and permissions.
4. Build an asynchronous document-ingestion pipeline.
5. Extract, chunk, embed, and index document content.
6. Implement semantic and keyword-based retrieval.
7. Generate grounded answers using an LLM.
8. Provide verifiable citations and handle unsupported questions.
9. Implement authentication, authorization, audit logging, and usage tracking.
10. Automate testing, deployment, monitoring, and recovery workflows.

---

## 3. Key Features

### 3.1 Organization and team management

- Create and manage organizations.
- Invite or add organization members.
- Assign organization-level roles.
- Manage membership status.
- Enforce organization-specific resource access.
- Record sensitive administrative actions.

### 3.2 Knowledge-base management

- Create knowledge bases within an organization.
- Associate documents with their owning knowledge base.
- List and manage authorized knowledge bases.
- Maintain document-processing and indexing status.
- Support document versioning and reindexing.

### 3.3 Document management

- Upload supported document formats.
- Validate file types and file sizes.
- Store original documents in object storage.
- Track document metadata and checksums.
- Process documents asynchronously.
- Retry failed ingestion jobs.
- Delete documents and their derived searchable content.

### 3.4 AI-powered question answering

- Ask natural-language questions.
- Retrieve semantically relevant passages.
- Combine vector search with keyword search.
- Rerank retrieved passages where configured.
- Generate context-grounded answers.
- Display source documents and page references when available.
- Stream responses using Server-Sent Events (SSE), where supported.
- Return an explicit uncertainty response when sufficient evidence is unavailable.

### 3.5 Security and governance

- OAuth 2.0 / OpenID Connect authentication.
- JWT-based API security.
- Organization-level authorization.
- Document-level permissions.
- PostgreSQL row-level security as defense in depth.
- Audit logs for sensitive actions.
- Rate limiting and usage tracking.
- Secure secret management and encrypted data storage.

### 3.6 Operations and observability

- Track ingestion-job status and failures.
- Retry transient processing failures.
- Monitor API latency and error rates.
- Track retrieval quality, LLM latency, and token usage.
- Collect metrics and distributed traces.
- Support automated tests and CI/CD.

---

## 4. Technology Stack

| Component | Technology | Responsibility |
|---|---|---|
| Frontend | Next.js, React, TypeScript | User interface and application workflows |
| Styling | Tailwind CSS | Responsive UI styling |
| Business backend | Java 21+, Spring Boot | Business logic and REST APIs |
| API security | Spring Security | Authentication and authorization |
| Persistence | Spring Data JPA | Relational data access |
| AI/RAG service | Python, FastAPI, Pydantic | Retrieval and generation orchestration |
| Primary database | PostgreSQL | Business data and document metadata |
| Vector search | pgvector | Embedding storage and similarity search |
| Keyword search | PostgreSQL full-text search | Lexical retrieval |
| Cache and rate limiting | Redis | Caching and request controls |
| Message broker | RabbitMQ | Asynchronous ingestion jobs |
| Object storage | Amazon S3 / MinIO | Original document storage |
| Embeddings | Sentence Transformers or configurable API | Text and query vector generation |
| Language model | Configurable hosted or local LLM | Answer generation |
| Authentication provider | OIDC-compatible provider | Identity management |
| API documentation | OpenAPI / Swagger | API contracts and exploration |
| Metrics | Prometheus | Metrics collection |
| Dashboards | Grafana | Operational visibility |
| Tracing | OpenTelemetry | Distributed tracing |
| Backend testing | JUnit 5, Testcontainers | Unit and integration testing |
| AI service testing | Pytest | Python unit and integration testing |
| Containers | Docker, Docker Compose | Local development and deployment |
| CI/CD | GitHub Actions | Automated quality checks and delivery |
| Database migrations | Flyway or Liquibase | Version-controlled schema changes |

### Architectural separation

**Spring Boot** owns the business domain, authentication, tenant authorization, organization membership, document lifecycle, and public API contracts.

**FastAPI** owns document-processing and RAG orchestration, including text preparation, embedding integration, retrieval, reranking, and generation.

**RabbitMQ** coordinates asynchronous ingestion.

**PostgreSQL with pgvector** stores relational application data and searchable document chunks.

**S3 or MinIO** stores original uploaded files.

The LLM and embedding providers should be configurable rather than tightly coupled to a single vendor.

---

## 5. System Architecture

### 5.1 High-level architecture

```text
                         Users
                           |
                           v
                  Next.js Frontend
                           |
                           v
                 Spring Boot API / BFF
                           |
               Authentication & Authorization
                           |
             +-------------+-------------+
             |             |             |
             v             v             v
        PostgreSQL       Redis       Object Storage
        + pgvector      Cache        S3 / MinIO
             |
             v
         RabbitMQ
             |
             v
      Ingestion Workers
             |
             v
       Text Extraction
             |
             v
        Text Chunking
             |
             v
       Embedding Service
             |
             v
     PostgreSQL + pgvector
             |
             v
     Hybrid Retrieval
             |
             v
       Reranking (Optional)
             |
             v
      FastAPI RAG Service
             |
             v
         LLM Gateway
             |
             v
     Grounded Answer + Citations
             |
             v
       Spring Boot API
             |
             v
       Next.js Frontend
```

### 5.2 Service responsibilities

| Service | Responsibilities |
|---|---|
| Frontend | Organization management, uploads, chat, citations, and dashboards |
| Spring Boot API | Business rules, membership checks, authorization, resource management, and public endpoints |
| PostgreSQL | Organizations, users, documents, conversations, permissions, and application metadata |
| pgvector | Embedding storage and vector similarity queries |
| Redis | Cache, rate limiting, and other short-lived operational data |
| RabbitMQ | Job dispatch, asynchronous processing, and retry coordination |
| Ingestion workers | Extraction, chunking, embedding, and indexing |
| Object storage | Original document files |
| FastAPI RAG service | Retrieval orchestration, context construction, and answer generation |
| LLM gateway | Provider abstraction, model invocation, timeouts, and usage reporting |
| Observability stack | Metrics, traces, dashboards, and alerting |

### 5.3 Architectural guidelines

- Keep business rules out of controllers.
- Keep tenant authorization in trusted backend code.
- Do not allow the AI service to bypass authorization.
- Avoid placing large original files directly in PostgreSQL.
- Use background jobs for potentially long-running ingestion operations.
- Use versioned API endpoints.
- Maintain clear contracts between Spring Boot and FastAPI.
- Keep model-provider integrations behind replaceable interfaces.

---

## 6. User Roles and Permissions

The platform defines three primary roles: Platform Admin, Organization Admin, and Member.

The role model must be enforced by the backend. Hiding a button in the frontend is not sufficient authorization.

### 6.1 Platform Admin

A Platform Admin manages platform-level operations across organizations.

**Responsibilities:**

- View platform-level organization information.
- Create, suspend, or manage organizations according to platform policy.
- Inspect operational health and ingestion failures.
- Review platform-level usage and operational metrics.
- Manage platform configuration and administrative controls.

**Restrictions:**

- Cross-tenant access to private document content should not be implicit.
- Any privileged access to tenant content must follow an explicit authorization policy and be audited.
- Platform administration must not bypass security checks silently.

### 6.2 Organization Admin

An Organization Admin manages their own organization's resources.

**Responsibilities:**

- Manage organization settings permitted by the application.
- Add or remove members.
- Assign organization roles within allowed limits.
- Create and manage knowledge bases.
- Upload, view, reindex, and delete authorized documents.
- Review ingestion-job status.
- Review organization-level usage and audit information, subject to permissions.

**Restrictions:**

- Cannot manage another organization's members or resources.
- Cannot change platform-wide settings.
- Cannot grant themselves platform-level privileges.

### 6.3 Member

A Member uses knowledge bases and documents they are authorized to access.

**Responsibilities:**

- View accessible knowledge bases.
- Upload documents if permitted.
- Search authorized document collections.
- Ask questions and view AI-generated answers.
- Open citations and source documents they are authorized to access.
- View their permitted conversation history.

**Restrictions:**

- Cannot manage organization membership.
- Cannot change organization-wide settings.
- Cannot access restricted documents or administrative functions.
- Cannot retrieve another organization's data by guessing resource identifiers.

### 6.4 Permission matrix

| Action | Platform Admin | Organization Admin | Member |
|---|---|---|---|
| Manage platform organizations | Yes | No | No |
| View platform operational metrics | Yes | No | No |
| Manage organization members | Platform policy | Own organization | No |
| Manage organization settings | Explicit policy | Own organization | No |
| Create knowledge bases | Only with applicable tenant authorization | Own organization | If granted |
| Upload documents | Only with applicable tenant authorization | Own organization | If granted |
| Search authorized documents | Explicit authorization | Own organization and permitted documents | Permitted documents |
| Ask questions | Subject to tenant access policy | Own organization and permitted documents | Permitted documents |
| Delete documents | Explicit authorization | Own organization, subject to policy | If granted |
| Inspect ingestion failures | Platform operations | Own organization | Limited status, if exposed |
| View organization usage | Platform-wide authorized metrics | Own organization | Own usage, if exposed |

**Important:** The exact role permissions should be implemented as explicit policies and refined as the product develops. Organization roles and document permissions are separate authorization layers.

### 6.5 Recommended authorization model

Use role-based access control (RBAC) for broad responsibilities and resource-level checks for specific documents.

```text
Authenticated User
       |
       v
Resolve Organization Membership
       |
       v
Validate Organization Role
       |
       v
Check Resource Ownership
       |
       v
Check Document Permissions
       |
       v
Allow or Deny Operation
```

A request should be rejected if any required authorization check fails.

---

## 7. Project Structure

The following is a proposed monorepo layout. Adapt paths to the actual implementation as services are created.

```text
enterprise-ai-knowledge-platform/
|
|-- frontend/
|   |-- app/
|   |-- components/
|   |-- features/
|   |   |-- organizations/
|   |   |-- knowledge-bases/
|   |   |-- documents/
|   |   |-- chat/
|   |   |-- administration/
|   |-- hooks/
|   |-- lib/
|   |-- types/
|   |-- public/
|   |-- tests/
|   |-- package.json
|   `-- README.md
|
|-- backend/
|   |-- src/
|   |   |-- main/
|   |   |   |-- java/
|   |   |   |   `-- com/example/knowledge/
|   |   |   |       |-- config/
|   |   |   |       |-- security/
|   |   |   |       |-- organization/
|   |   |   |       |-- membership/
|   |   |   |       |-- knowledgebase/
|   |   |   |       |-- document/
|   |   |   |       |-- conversation/
|   |   |   |       |-- usage/
|   |   |   |       |-- audit/
|   |   |   |       |-- common/
|   |   |   |       `-- exception/
|   |   |   `-- resources/
|   |   |       |-- application.yml
|   |   |       `-- db/migration/
|   |   `-- test/
|   |-- pom.xml
|   `-- README.md
|
|-- ai-service/
|   |-- app/
|   |   |-- api/
|   |   |-- core/
|   |   |-- ingestion/
|   |   |-- extraction/
|   |   |-- chunking/
|   |   |-- embeddings/
|   |   |-- retrieval/
|   |   |-- reranking/
|   |   |-- generation/
|   |   |-- providers/
|   |   |-- security/
|   |   `-- schemas/
|   |-- tests/
|   |-- pyproject.toml
|   `-- README.md
|
|-- infrastructure/
|   |-- docker/
|   |-- monitoring/
|   |-- scripts/
|   `-- README.md
|
|-- docs/
|   |-- architecture.md
|   |-- database-design.md
|   |-- api-specification.md
|   |-- security.md
|   |-- rag-pipeline.md
|   `-- deployment.md
|
|-- .github/
|   `-- workflows/
|
|-- .env.example
|-- .gitignore
|-- compose.yaml
`-- README.md
```

This structure is a design proposal, not a claim that every directory or service already exists.

---

## 8. Database Design

The database uses UUID primary keys, foreign-key relationships, UTC timestamps, indexes, and tenant-aware constraints.

### 8.1 Core entities

#### Organizations

Stores tenant-level information.

| Column | Purpose |
|---|---|
| `id` | Organization UUID |
| `name` | Organization name |
| `slug` | Unique organization identifier |
| `status` | Organization lifecycle status |
| `created_at` | Creation timestamp |

#### Users

Stores application-level user identity information.

| Column | Purpose |
|---|---|
| `id` | User UUID |
| `email` | User email |
| `name` | Display name |
| `identity_provider_id` | External identity reference |
| `created_at` | Creation timestamp |

#### Organization Members

Associates users with organizations.

| Column | Purpose |
|---|---|
| `id` | Membership UUID |
| `organization_id` | Organization reference |
| `user_id` | User reference |
| `role` | Organization-level role |
| `status` | Membership status |

Recommended constraint: unique membership for each `(organization_id, user_id)` pair.

#### Knowledge Bases

Stores knowledge-base metadata.

| Column | Purpose |
|---|---|
| `id` | Knowledge-base UUID |
| `organization_id` | Owning organization |
| `name` | Knowledge-base name |
| `description` | Optional description |
| `created_by` | Creator user ID |
| `created_at` | Creation timestamp |

#### Documents

Stores document metadata and lifecycle state.

| Column | Purpose |
|---|---|
| `id` | Document UUID |
| `organization_id` | Owning organization |
| `knowledge_base_id` | Parent knowledge base |
| `uploaded_by` | Uploading user |
| `filename` | Original filename |
| `object_key` | Object-storage key |
| `mime_type` | Detected or validated media type |
| `checksum` | Content integrity and deduplication reference |
| `version` | Document version |
| `status` | Processing or lifecycle status |
| `created_at` | Creation timestamp |

#### Document Permissions

Stores document-specific access grants.

| Column | Purpose |
|---|---|
| `id` | Permission UUID |
| `document_id` | Protected document |
| `principal_type` | Type of principal, such as user or role |
| `principal_id` | Authorized principal identifier |
| `permission` | Granted permission |

Permission evaluation must validate the principal against the current tenant and the applicable resource.

#### Document Chunks

Stores extracted passages and their vector representations.

| Column | Purpose |
|---|---|
| `id` | Chunk UUID |
| `organization_id` | Tenant identifier |
| `document_id` | Source document |
| `chunk_index` | Position within the document |
| `content` | Extracted text passage |
| `page_number` | Source page, when available |
| `metadata` | Additional structured metadata |
| `embedding` | Vector representation |

The vector column dimension must match the configured embedding model.

#### Conversations

Stores chat sessions.

| Column | Purpose |
|---|---|
| `id` | Conversation UUID |
| `organization_id` | Owning organization |
| `user_id` | Conversation owner |
| `title` | Conversation title |
| `created_at` | Creation timestamp |

#### Messages

Stores conversation messages.

| Column | Purpose |
|---|---|
| `id` | Message UUID |
| `conversation_id` | Parent conversation |
| `role` | User or assistant |
| `content` | Message content |
| `created_at` | Creation timestamp |

#### Message Citations

Associates answers with their supporting sources.

| Column | Purpose |
|---|---|
| `id` | Citation UUID |
| `message_id` | Answer message |
| `chunk_id` | Supporting chunk |
| `document_id` | Source document |
| `page_number` | Source page, when available |
| `relevance_score` | Retrieval or reranking score |

#### Ingestion Jobs

Tracks asynchronous document processing.

| Column | Purpose |
|---|---|
| `id` | Job UUID |
| `organization_id` | Tenant identifier |
| `document_id` | Source document |
| `status` | Job status |
| `attempt_count` | Number of attempts |
| `error_message` | Sanitized failure details |
| `created_at` | Creation timestamp |
| `updated_at` | Last update timestamp |

#### Audit Logs

Records security-sensitive and administrative actions.

| Column | Purpose |
|---|---|
| `id` | Audit record UUID |
| `organization_id` | Relevant tenant, when applicable |
| `actor_id` | Acting user or system identity |
| `action` | Operation performed |
| `resource_type` | Affected resource type |
| `resource_id` | Affected resource ID |
| `created_at` | Event timestamp |

#### Usage Records

Tracks model usage and estimated cost.

| Column | Purpose |
|---|---|
| `id` | Usage record UUID |
| `organization_id` | Tenant identifier |
| `user_id` | Associated user |
| `operation` | Operation type |
| `input_tokens` | Input tokens, where available |
| `output_tokens` | Output tokens, where available |
| `estimated_cost` | Estimated operation cost |
| `created_at` | Usage timestamp |

### 8.2 Entity relationships

```text
Organization
  |
  +---- Organization Members ---- User
  |
  +---- Knowledge Bases
  |          |
  |          +---- Documents
  |                    |
  |                    +---- Document Permissions
  |                    +---- Document Chunks
  |                    +---- Ingestion Jobs
  |
  +---- Conversations ---- User
              |
              +---- Messages
                        |
                        +---- Message Citations
                                  |
                                  +---- Document Chunks
                                  +---- Documents
  |
  +---- Audit Logs
  |
  +---- Usage Records
```

### 8.3 Database design requirements

- Use UUID primary keys and explicit foreign keys.
- Use UTC timestamps.
- Index organization IDs, foreign keys, status fields, and commonly queried timestamps.
- Add composite tenant-aware constraints where appropriate.
- Use pgvector for embeddings and similarity search.
- Consider HNSW vector indexes when justified by measured query workloads.
- Use PostgreSQL full-text search for lexical retrieval.
- Apply PostgreSQL row-level security as defense in depth.
- Use Flyway or Liquibase for schema migrations.
- Store original files in object storage.
- Define retention, archival, and deletion policies.
- Ensure document versions and indexing operations do not produce duplicate active chunks.

---

## 9. Core Workflows

### 9.1 Authentication and organization access

1. The user authenticates through an OIDC-compatible identity provider.
2. Spring Security validates the authentication result.
3. The backend resolves the internal user and organization memberships.
4. The request selects an authorized organization context.
5. The backend validates the user's role and resource permissions.
6. Sensitive operations produce audit events.
7. The request proceeds only after authorization succeeds.

### 9.2 Document ingestion

1. The user uploads a supported document.
2. The backend validates the user's permissions, file type, and file size.
3. The original file is stored in S3 or MinIO.
4. A document record and idempotent ingestion job are created.
5. RabbitMQ dispatches the processing job.
6. A worker extracts text and page metadata.
7. Extracted text is split into chunks.
8. The embedding service generates vectors.
9. Chunks and embeddings are stored in PostgreSQL with pgvector.
10. The document becomes searchable only after successful indexing.
11. Failures trigger bounded retries and dead-letter handling where configured.

### 9.3 Question answering

1. The user submits a question.
2. The backend validates organization membership and conversation access.
3. Knowledge-base and document permissions are resolved.
4. The question is embedded.
5. Authorized candidates are retrieved using vector and keyword search.
6. The system merges and optionally reranks the candidates.
7. The most relevant authorized passages are selected.
8. The question and selected context are sent to the configured LLM.
9. The generated answer is checked for citation and evidence requirements.
10. The answer and citation references are persisted.
11. The frontend receives the response and displays the supporting sources.
12. Usage and performance metrics are recorded.

### 9.4 Document lifecycle

The platform should support:

- Upload and validation.
- Processing and indexing.
- Processing failure and retry.
- Document updates and versioning.
- Explicit reindexing.
- Archival, where applicable.
- Deletion of the original file.
- Deletion of related chunks and embeddings.
- Cleanup of derived references according to retention policy.

Deletion must account for object storage, database records, vector indexes, caches, and derived data. A failed cleanup operation should be observable and recoverable.

---

## 10. API Documentation

All public endpoints use the `/api/v1` prefix.

Authentication, authorization, request validation, pagination, consistent errors, and tenant isolation must be applied as appropriate.

### 10.1 Organization APIs

| Method | Endpoint | Purpose |
|---|---|---|
| `POST` | `/api/v1/organizations` | Create an organization |
| `GET` | `/api/v1/organizations` | List organizations visible to the caller |
| `GET` | `/api/v1/organizations/{id}` | Retrieve an authorized organization |
| `PATCH` | `/api/v1/organizations/{id}` | Update permitted organization settings |

### 10.2 Membership APIs

| Method | Endpoint | Purpose |
|---|---|---|
| `POST` | `/api/v1/organizations/{id}/members` | Add or invite a member |
| `GET` | `/api/v1/organizations/{id}/members` | List authorized members |
| `PATCH` | `/api/v1/organizations/{id}/members/{memberId}` | Update membership or role |
| `DELETE` | `/api/v1/organizations/{id}/members/{memberId}` | Remove a membership |

### 10.3 Knowledge-base APIs

| Method | Endpoint | Purpose |
|---|---|---|
| `POST` | `/api/v1/knowledge-bases` | Create a knowledge base |
| `GET` | `/api/v1/knowledge-bases` | List accessible knowledge bases |
| `GET` | `/api/v1/knowledge-bases/{id}` | Retrieve a knowledge base |
| `PATCH` | `/api/v1/knowledge-bases/{id}` | Update a knowledge base |
| `DELETE` | `/api/v1/knowledge-bases/{id}` | Delete or archive a knowledge base according to policy |

### 10.4 Document APIs

| Method | Endpoint | Purpose |
|---|---|---|
| `POST` | `/api/v1/knowledge-bases/{id}/documents` | Upload a document |
| `GET` | `/api/v1/documents/{id}` | Retrieve authorized document metadata |
| `GET` | `/api/v1/knowledge-bases/{id}/documents` | List documents in an authorized knowledge base |
| `DELETE` | `/api/v1/documents/{id}` | Delete an authorized document |
| `POST` | `/api/v1/documents/{id}/reindex` | Request reindexing |
| `GET` | `/api/v1/documents/{id}/status` | Retrieve processing status |

### 10.5 Conversation APIs

| Method | Endpoint | Purpose |
|---|---|---|
| `POST` | `/api/v1/conversations` | Create a conversation |
| `GET` | `/api/v1/conversations` | List the caller's accessible conversations |
| `POST` | `/api/v1/conversations/{id}/messages` | Submit a question |
| `GET` | `/api/v1/conversations/{id}/messages` | Retrieve conversation messages |

### 10.6 Operations and usage APIs

| Method | Endpoint | Purpose |
|---|---|---|
| `GET` | `/api/v1/usage` | Retrieve authorized usage information |
| `GET` | `/api/v1/admin/ingestion-jobs` | Inspect authorized ingestion jobs |
| `GET` | `/actuator/health` | Check backend health, if exposed |
| `GET` | `/v3/api-docs` | Retrieve the generated OpenAPI specification, if enabled |
| `GET` | `/swagger-ui/index.html` | Explore documented APIs, if enabled |

Operational endpoints must be protected appropriately and should not expose sensitive internal information.

### 10.7 API conventions

- Validate request bodies and path parameters.
- Return consistent HTTP status codes.
- Use pagination for collection endpoints.
- Enforce resource authorization on every request.
- Use idempotency keys for applicable operations.
- Apply rate limits to expensive endpoints.
- Return correlation IDs for troubleshooting.
- Avoid exposing stack traces or internal secrets.
- Use SSE for streaming AI responses where appropriate.
- Document authentication requirements and error schemas in OpenAPI.

### 10.8 Example API request

Create a knowledge base:

```http
POST /api/v1/knowledge-bases
Authorization: Bearer <access-token>
Content-Type: application/json
```

```json
{
  "name": "Engineering Documentation",
  "description": "Internal engineering guides and technical references"
}
```

Illustrative response:

```json
{
  "id": "00000000-0000-0000-0000-000000000001",
  "name": "Engineering Documentation",
  "description": "Internal engineering guides and technical references"
}
```

The response is illustrative; the actual schema and generated UUID depend on the implementation.

---

## 11. RAG Pipeline

Retrieval-Augmented Generation combines information retrieval with language-model generation. Instead of relying exclusively on the model's internal knowledge, the platform retrieves relevant organizational documents and uses their content as evidence.

### 11.1 Document ingestion pipeline

```text
Original Document
       |
       v
File Validation
       |
       v
Object Storage
       |
       v
Text Extraction
       |
       v
Text Normalization
       |
       v
Chunking + Metadata
       |
       v
Embedding Generation
       |
       v
PostgreSQL + pgvector
       |
       v
Document Ready for Search
```

### 11.2 Text extraction

Extract text from supported formats and preserve useful metadata, including:

- Original filename.
- Document identifier and version.
- Page number, when available.
- Section or heading information, when available.
- Chunk index.
- Tenant and knowledge-base identifiers.

Extraction failures should produce a meaningful processing status rather than silently indexing empty content.

### 11.3 Chunking

Long documents are split into smaller passages that can be retrieved independently.

Chunking should consider:

- Token or character limits.
- Paragraph and heading boundaries.
- Overlap between adjacent chunks where useful.
- Page boundaries and source references.
- Embedding-model input limits.
- Retrieval quality and context-window constraints.

Chunk size and overlap should be tuned through evaluation rather than treated as universal constants.

### 11.4 Embedding generation

Each chunk is converted into a vector representation by a configured embedding model.

The same compatible embedding configuration must be used for stored document vectors and query vectors. Changing models or vector dimensions may require re-embedding existing content.

### 11.5 Hybrid retrieval

The retrieval system combines:

**Semantic search:** Finds passages based on similarity between query and document embeddings.

**Keyword search:** Finds passages using lexical matching and PostgreSQL full-text search.

The two result sets can be combined using Reciprocal Rank Fusion (RRF), followed by optional cross-encoder reranking.

The final candidates must be filtered by tenant and document permissions before their content is passed to the LLM.

### 11.6 Grounded generation

The generation service receives:

- The user's question.
- Authorized retrieved passages.
- Source identifiers and page metadata.
- Instructions to distinguish evidence from uncertainty.

The LLM should not be allowed to invent citations or claim that a document supports an assertion when it does not.

### 11.7 Citation handling

Citations should reference persisted source metadata rather than arbitrary document IDs generated by the model.

Where available, include:

- Source document title.
- Document identifier or version.
- Page number.
- Relevant passage.
- Retrieval or reranking score for internal evaluation.

If no sufficiently relevant evidence is available, the system should clearly communicate uncertainty rather than generate an unsupported answer.

### 11.8 Advanced RAG capabilities

Planned enhancements include:

- Reciprocal Rank Fusion.
- Cross-encoder reranking.
- Query rewriting.
- Multi-query retrieval.
- Metadata-aware retrieval.
- Context-window optimization.
- Citation validation.
- Streaming answers.
- Incremental reindexing.
- Retrieval and answer-quality dashboards.

---

## 12. Security and Multi-Tenant Isolation

Security is a core architectural requirement, not an optional feature.

### 12.1 Tenant isolation

Every tenant-owned resource must have a verifiable relationship to its owning organization.

A request must never gain access to another organization's data merely by supplying a different UUID or organization ID.

For example:

```text
Organization A
    |
    +---- Knowledge Base A
              |
              +---- Confidential HR Document

Organization B
    |
    +---- Knowledge Base B
```

A user from Organization B must not be able to retrieve the confidential HR document by:

- Guessing its document UUID.
- Changing a request path parameter.
- Modifying an organization ID in the request body.
- Submitting a crafted search query.
- Accessing another organization's conversation.
- Exploiting an unfiltered vector search result.

### 12.2 Authorization requirements

- Resolve tenant context from authenticated identity and verified membership.
- Validate organization membership for every tenant-scoped operation.
- Verify that knowledge bases and documents belong to the selected tenant.
- Apply document-level permission checks where configured.
- Filter retrieval results before building LLM context.
- Revalidate authorization when resolving citations and source previews.
- Scope caches and rate limits to the appropriate tenant or principal.
- Prevent unauthorized access to ingestion jobs and usage data.
- Avoid trusting client-supplied ownership fields.
- Record sensitive administrative actions.

### 12.3 Defense in depth

Use multiple complementary controls:

1. Application-level authorization.
2. Tenant-aware repository queries.
3. Tenant-aware foreign keys and database constraints.
4. PostgreSQL row-level security where appropriate.
5. Document-level permission checks.
6. Authorization-aware retrieval.
7. Tests for cross-tenant access.
8. Audit logging and security monitoring.

Database row-level security should supplement, not replace, application authorization.

### 12.4 Authentication and secrets

- Use an OIDC-compatible identity provider.
- Validate tokens and their relevant claims.
- Use short-lived access tokens where appropriate.
- Protect refresh tokens and signing keys.
- Store secrets in environment-specific secret management systems.
- Require TLS in deployed environments.
- Encrypt sensitive data at rest and in transit.
- Never commit `.env` files or credentials to version control.

### 12.5 Document and prompt-injection security

Uploaded documents and retrieved passages are untrusted input.

- Validate file types and sizes.
- Consider malware scanning.
- Use safe parsers and extraction limits.
- Treat document instructions as data, not privileged system instructions.
- Do not execute arbitrary code, SQL, or tools based on LLM output.
- Restrict tool access and model capabilities.
- Avoid returning retrieved content that the requesting user is not authorized to see.
- Avoid logging unnecessary document contents or personal data.

### 12.6 Reliability and abuse prevention

- Apply request rate limits and model-provider quotas.
- Configure LLM timeouts and bounded retries.
- Use circuit breakers where appropriate.
- Make ingestion workers idempotent.
- Use retry queues and dead-letter handling.
- Consider transactional outbox patterns for reliable database-to-message dispatch.
- Track failed deletions and cleanup operations.
- Define data-retention and backup policies.

---

## 13. Getting Started

This section describes the intended local-development setup. Commands depend on the actual repository structure and configuration files.

### 13.1 Prerequisites

Install the following tools:

- Git.
- Java 21 or later.
- Maven, if the backend is not using the Maven wrapper.
- Python and a supported virtual environment tool.
- Node.js and npm.
- Docker and Docker Compose.
- PostgreSQL with pgvector, or a compatible configured container.
- An OIDC identity provider or local development authentication configuration.
- Credentials for a configured LLM and embedding provider, if using hosted services.

MinIO can be used for local object storage instead of Amazon S3.

### 13.2 Clone the repository

```bash
git clone <repository-url>
cd enterprise-ai-knowledge-platform
```

Replace `<repository-url>` with the actual repository URL.

### 13.3 Configure environment variables

Create local environment configuration using the provided example:

```bash
cp .env.example .env
```

If `.env.example` does not exist yet, create it using the configuration section below.

Populate the required database, object-storage, authentication, message-broker, embedding, and LLM settings.

Do not commit real credentials.

### 13.4 Start infrastructure services

If the repository contains a configured Compose file:

```bash
docker compose up -d
```

Verify service health:

```bash
docker compose ps
```

The Compose configuration should provide the required local services, such as PostgreSQL with pgvector, Redis, RabbitMQ, and MinIO.

A Compose file must actually define these services before this command can start them.

### 13.5 Run database migrations

Configure the database connection and run the migrations through the project's configured Flyway or Liquibase workflow.

For Maven projects using Flyway, the exact command depends on the available plugin and build configuration. An example is:

```bash
./mvnw flyway:migrate
```

On Windows, use the appropriate Maven wrapper script. If the project does not configure the Flyway Maven plugin, use the migration workflow defined by the project.

### 13.6 Run the Spring Boot backend

From the backend directory:

```bash
cd backend
./mvnw spring-boot:run
```

If the Maven wrapper is unavailable, use Maven directly:

```bash
mvn spring-boot:run
```

### 13.7 Run the AI service

From the AI service directory:

```bash
cd ai-service
python -m venv .venv
```

Activate the virtual environment.

Linux/macOS:

```bash
source .venv/bin/activate
```

Windows PowerShell:

```powershell
.venv\Scripts\Activate.ps1
```

Install dependencies using the project's dependency file:

```bash
pip install -e .
```

If the project uses a different dependency manager or does not yet define a package configuration, follow the actual service setup instructions.

An illustrative FastAPI launch command is:

```bash
uvicorn app.main:app --reload --port 8000
```

This command assumes the service exposes an ASGI application at `app.main:app`.

### 13.8 Run the frontend

From the frontend directory:

```bash
cd frontend
npm install
npm run dev
```

Configure the frontend to use the backend API URL and the appropriate authentication settings.

### 13.9 Verify the services

Once implemented and configured, verify:

- The frontend loads.
- The Spring Boot backend starts successfully.
- The AI service responds to health checks.
- PostgreSQL migrations complete.
- RabbitMQ and Redis are reachable.
- Object storage accepts and retrieves test files.
- Authentication works.
- Organization and document authorization tests pass.
- A test document can be uploaded, indexed, searched, and cited.

---

## 14. Environment Configuration

The following is an illustrative environment-variable template. Adapt the names to the actual configuration used by each service.

```dotenv
# Application
APP_ENV=local
APP_BASE_URL=http://localhost:3000
API_BASE_URL=http://localhost:8080
AI_SERVICE_URL=http://localhost:8000

# PostgreSQL
POSTGRES_DB=knowledge_platform
POSTGRES_USER=knowledge_app
POSTGRES_PASSWORD=replace_with_local_secret
DATABASE_URL=jdbc:postgresql://localhost:5432/knowledge_platform

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379

# RabbitMQ
RABBITMQ_HOST=localhost
RABBITMQ_PORT=5672
RABBITMQ_USER=replace_with_local_user
RABBITMQ_PASSWORD=replace_with_local_secret

# Object Storage - MinIO / S3
OBJECT_STORAGE_ENDPOINT=http://localhost:9000
OBJECT_STORAGE_BUCKET=knowledge-documents
OBJECT_STORAGE_ACCESS_KEY=replace_with_local_access_key
OBJECT_STORAGE_SECRET_KEY=replace_with_local_secret
OBJECT_STORAGE_REGION=us-east-1

# Authentication - OIDC
OIDC_ISSUER_URI=
OIDC_CLIENT_ID=
OIDC_CLIENT_SECRET=

# Embeddings
EMBEDDING_PROVIDER=
EMBEDDING_MODEL=
EMBEDDING_DIMENSIONS=

# LLM
LLM_PROVIDER=
LLM_MODEL=
LLM_API_KEY=

# Observability
OTEL_EXPORTER_OTLP_ENDPOINT=
```

**Important configuration notes:**

- This is a template, not a verified configuration for the current repository.
- Do not use placeholder secrets in a deployed environment.
- Keep provider API keys server-side.
- Configure embedding dimensions to match the selected model and database schema.
- Configure database, Redis, and RabbitMQ credentials independently for production.
- Use a managed secret store or deployment secrets mechanism in production.
- Do not expose administrative service endpoints publicly without authentication.

---

## 15. Development Roadmap

The project is divided into phases to support incremental development and validation.

### Phase 1 — Foundation and database design

- [ ] Define project architecture and service boundaries.
- [ ] Set up the Spring Boot project.
- [ ] Configure PostgreSQL and database migrations.
- [ ] Create organization, user, membership, and knowledge-base entities.
- [ ] Implement repositories, services, DTOs, and controllers.
- [ ] Implement validation and consistent error handling.
- [ ] Create initial organization and knowledge-base APIs.
- [ ] Write basic unit and integration tests.

**Deliverable:** A functioning business API with a versioned database schema.

### Phase 2 — Authentication and authorization

- [ ] Configure Spring Security.
- [ ] Integrate an OIDC-compatible identity provider.
- [ ] Resolve organization memberships and roles.
- [ ] Implement tenant-aware authorization.
- [ ] Enforce organization and resource ownership.
- [ ] Add document-level permission checks.
- [ ] Add tenant-isolation integration tests.
- [ ] Configure PostgreSQL row-level security where appropriate.

**Deliverable:** Authenticated APIs that prevent cross-tenant access.

### Phase 3 — Document management and ingestion

- [ ] Implement document-upload endpoints.
- [ ] Integrate S3 or MinIO.
- [ ] Create document metadata and lifecycle states.
- [ ] Configure RabbitMQ.
- [ ] Implement asynchronous ingestion jobs.
- [ ] Add text extraction and normalization.
- [ ] Implement chunking and metadata preservation.
- [ ] Generate embeddings.
- [ ] Store chunks and vectors in PostgreSQL with pgvector.
- [ ] Implement retries and duplicate-processing protection.
- [ ] Add document reindexing and deletion workflows.

**Deliverable:** An end-to-end document ingestion pipeline.

### Phase 4 — Retrieval and AI question answering

- [ ] Implement vector similarity search.
- [ ] Implement PostgreSQL full-text search.
- [ ] Combine retrieval results using a suitable ranking strategy.
- [ ] Add optional reranking.
- [ ] Enforce authorization-aware retrieval.
- [ ] Integrate the LLM gateway.
- [ ] Generate grounded answers.
- [ ] Validate and persist citations.
- [ ] Implement unsupported-answer handling.
- [ ] Add streaming responses where appropriate.
- [ ] Evaluate retrieval and answer quality.

**Deliverable:** A functional RAG question-answering workflow.

### Phase 5 — Frontend and product workflows

- [ ] Build authentication and organization selection.
- [ ] Implement organization and membership management.
- [ ] Build knowledge-base dashboards.
- [ ] Add document uploads and status indicators.
- [ ] Implement AI chat and conversation history.
- [ ] Display citations and source navigation.
- [ ] Build usage and cost views.
- [ ] Add authorized administrative views.

**Deliverable:** An integrated end-user application.

### Phase 6 — Reliability and observability

- [ ] Configure Redis-based caching where appropriate.
- [ ] Implement rate limiting.
- [ ] Configure retries, timeouts, and dead-letter handling.
- [ ] Add structured logs and correlation IDs.
- [ ] Instrument OpenTelemetry traces.
- [ ] Expose Prometheus metrics.
- [ ] Create Grafana dashboards.
- [ ] Implement audit logging.
- [ ] Add ingestion failure recovery.
- [ ] Review backup and deletion procedures.

**Deliverable:** An observable and recoverable application.

### Phase 7 — CI/CD and production readiness

- [ ] Add automated build and test workflows.
- [ ] Run unit and integration tests in CI.
- [ ] Add security and dependency checks.
- [ ] Containerize the services.
- [ ] Configure deployment environments.
- [ ] Document secrets and configuration management.
- [ ] Run load and authorization tests.
- [ ] Evaluate retrieval quality and latency.
- [ ] Document backup, restoration, and incident procedures.
- [ ] Complete a production-readiness review.

**Deliverable:** A documented, testable, deployable application.

---

## 16. Testing Strategy

Testing must cover functional correctness, security boundaries, retrieval quality, and operational failure scenarios.

### 16.1 Backend unit tests

Use JUnit 5 to test:

- Service-layer business rules.
- Membership and role validation.
- Resource ownership checks.
- DTO validation.
- Exception handling.
- Document lifecycle transitions.
- Ingestion-job state transitions.
- Usage calculations.

### 16.2 Backend integration tests

Use Testcontainers to test interactions with real or containerized dependencies.

Recommended coverage:

- PostgreSQL persistence.
- Database migrations.
- Tenant-aware queries.
- PostgreSQL row-level security.
- Document and knowledge-base relationships.
- Authentication and authorization filters.
- Transaction boundaries.
- Idempotent operations.
- RabbitMQ publishing and consumption where applicable.

### 16.3 AI service tests

Use Pytest to test:

- Text extraction.
- Chunking and metadata.
- Embedding-provider interfaces.
- Vector and keyword retrieval.
- Ranking and reranking.
- Context construction.
- Citation generation and validation.
- Unsupported-answer handling.
- Provider timeout and failure behavior.
- Prompt-injection resilience.

Use mocks for deterministic unit tests and integration tests for configured providers and storage systems.

### 16.4 Tenant-isolation tests

Create at least two organizations with separate users and documents.

Verify that:

- Organization B cannot retrieve Organization A's document.
- Guessing a valid document UUID does not grant access.
- A modified organization ID cannot bypass membership checks.
- Search results exclude unauthorized chunks.
- Citations do not reveal unauthorized source metadata.
- Conversation history is isolated.
- Ingestion jobs and usage records are tenant-scoped.
- Document deletion does not affect another tenant's data.
- Cache keys cannot cause cross-tenant data leakage.

These tests are mandatory security checks, not optional enhancements.

### 16.5 End-to-end tests

Test the full lifecycle:

1. Authenticate a user.
2. Create or select an authorized organization.
3. Create a knowledge base.
4. Upload a test document.
5. Wait for successful ingestion.
6. Ask a question answered by the document.
7. Verify that the answer references the correct source.
8. Ask an unsupported question.
9. Verify that uncertainty is communicated.
10. Attempt a cross-tenant request and confirm that it is denied.

---

## 17. Observability and Reliability

### 17.1 Metrics

Track operational metrics such as:

- API request count and error rate.
- API response latency.
- Database query latency.
- RabbitMQ queue depth.
- Ingestion-job success and failure rates.
- Document-processing duration.
- Embedding-generation latency.
- Retrieval latency.
- Reranking latency.
- LLM latency and timeout rate.
- Token usage and estimated cost.
- Citation validation failures.

### 17.2 Logging and tracing

Use structured logs and distributed tracing to correlate requests across Spring Boot, RabbitMQ workers, and FastAPI.

Logs should avoid:

- Passwords and secrets.
- Raw access tokens.
- Sensitive document contents unless explicitly justified.
- Unnecessary personal data.
- Unredacted provider credentials.

Use correlation identifiers and appropriate tenant identifiers for operational debugging without exposing confidential information.

### 17.3 Reliability controls

- Use bounded retries with backoff.
- Ensure workers can safely process duplicate messages.
- Implement dead-letter handling for repeatedly failing jobs.
- Track processing state transitions.
- Use timeouts for external service calls.
- Apply circuit breakers where appropriate.
- Handle partial failures between object storage and the database.
- Make cleanup and deletion operations observable.
- Establish database backup and restoration procedures.
- Define service-level objectives after collecting baseline performance data.

---

## 18. Evaluation Metrics

A successful RAG platform must be evaluated on both retrieval quality and answer quality.

| Metric | Purpose |
|---|---|
| Recall@K | Measures whether relevant passages appear among the top K retrieved results |
| Mean Reciprocal Rank (MRR) | Measures the position of the first relevant result |
| nDCG@K | Evaluates ranking quality across the top K results |
| Faithfulness | Measures whether generated claims are supported by the provided evidence |
| Citation correctness | Measures whether citations support the claims they accompany |
| Answer relevance | Measures how well the answer addresses the question |
| Unsupported-answer rate | Tracks answers generated without sufficient evidence |
| Retrieval latency | Measures the time needed to retrieve relevant passages |
| End-to-end latency | Measures the complete question-to-answer duration |
| Cost per query | Estimates the cost of retrieval, embeddings, and generation |

Maintain a repeatable evaluation dataset containing representative questions, expected sources, and expected answer characteristics.

Evaluate changes to chunking, embeddings, retrieval strategies, reranking, prompts, and model providers against the same dataset.

---

## 19. Deployment

The platform is intended to support containerized deployment.

### 19.1 Local development

Docker Compose can orchestrate local dependencies and application services.

Typical components include:

- Frontend.
- Spring Boot backend.
- FastAPI service.
- PostgreSQL with pgvector.
- Redis.
- RabbitMQ.
- MinIO.
- Prometheus and Grafana, when configured.

### 19.2 Production deployment considerations

- Use managed PostgreSQL or a suitably operated database.
- Configure backups and test restoration.
- Use private networking for internal services.
- Store secrets in a managed secret store.
- Enable TLS.
- Restrict object-storage permissions.
- Apply database migrations through a controlled release process.
- Configure application health checks.
- Establish autoscaling and resource limits based on measured workloads.
- Monitor queue depth and ingestion backlog.
- Define retention and deletion policies.
- Implement disaster-recovery procedures.
- Conduct security and load testing before production release.

### 19.3 CI/CD

A GitHub Actions workflow should perform relevant checks such as:

1. Code formatting and linting.
2. Backend compilation.
3. Backend unit tests.
4. Backend integration tests.
5. AI-service linting and tests.
6. Frontend type checking and tests.
7. Dependency and security scans.
8. Container image builds.
9. Migration validation.
10. Deployment to approved environments.

Deployment should be gated by the project's testing and security requirements.

---

## 20. Acceptance Criteria

The project is considered ready for its intended release when the following requirements have been demonstrated.

### Functional requirements

- [ ] Organizations and memberships can be managed through authorized APIs.
- [ ] Users can create and access authorized knowledge bases.
- [ ] Supported documents can be uploaded and processed asynchronously.
- [ ] Document chunks and embeddings are indexed successfully.
- [ ] Users can search authorized documents.
- [ ] AI answers use retrieved evidence.
- [ ] Answers include relevant citations and page references when available.
- [ ] Unsupported questions receive an explicit uncertainty response.
- [ ] Document updates, reindexing, and deletion are handled correctly.
- [ ] Failed ingestion jobs can be retried without duplicate indexed content.

### Security requirements

- [ ] Users cannot access another organization's documents or search results.
- [ ] Guessing UUIDs does not bypass authorization.
- [ ] Organization and document permissions are enforced on backend operations.
- [ ] Unauthorized chunks are excluded before LLM context construction.
- [ ] Citations and source previews enforce authorization.
- [ ] Administrative operations are restricted and audited.
- [ ] Secrets and tokens are not exposed in logs or committed to source control.

### Engineering requirements

- [ ] Database migrations are version-controlled.
- [ ] API validation and consistent error handling are implemented.
- [ ] Unit and integration tests run in CI.
- [ ] Tenant-isolation tests run in CI.
- [ ] Ingestion processing and failure recovery are observable.
- [ ] Retrieval quality, latency, and cost are measured.
- [ ] Deployment, configuration, and recovery procedures are documented.

---

## 21. Future Enhancements

Potential extensions include:

- Fine-grained group-based document access.
- Enterprise SSO and identity provisioning.
- Document classification and metadata extraction.
- OCR for scanned documents.
- Multilingual document search.
- Advanced hybrid ranking and adaptive retrieval.
- Query decomposition and multi-step retrieval.
- Knowledge-graph-assisted retrieval.
- Feedback-driven retrieval improvements.
- Evaluation datasets and automated regression reports.
- Organization-level quotas and subscription plans.
- Advanced usage analytics and billing.
- Additional file formats and connectors.
- Automated document retention and compliance workflows.
- Data residency and configurable retention policies.

These enhancements should be prioritized based on product requirements, security needs, and measured system performance.

---

## 22. Contributing

Contributions should follow the project's architecture, coding conventions, and security requirements.

### Recommended workflow

1. Create a feature branch.
2. Keep changes scoped to a specific feature or fix.
3. Add or update tests.
4. Run relevant formatting, linting, and test commands.
5. Verify authorization and tenant-isolation implications.
6. Update API documentation when contracts change.
7. Update database migrations when the schema changes.
8. Submit a pull request with a clear description and test results.

### Development guidelines

- Keep controllers thin and business logic in services.
- Use DTOs for API request and response contracts.
- Validate input at service boundaries.
- Prefer explicit authorization policies.
- Avoid cross-service dependencies on internal implementation details.
- Use database migrations rather than manual production schema changes.
- Make asynchronous workers idempotent.
- Avoid committing secrets, personal data, or confidential test documents.
- Document any security-sensitive architectural decisions.

---


