CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(200) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE'
        CHECK (status IN ('ACTIVE', 'SUSPENDED', 'DELETED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(320) NOT NULL UNIQUE,
    name VARCHAR(200) NOT NULL,
    identity_provider_id VARCHAR(255) UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE organization_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL
        REFERENCES organizations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL
        REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(30) NOT NULL
        CHECK (role IN ('ORG_ADMIN', 'MEMBER')),
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE'
        CHECK (status IN ('ACTIVE', 'INVITED', 'SUSPENDED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_org_member UNIQUE (organization_id, user_id)
);

CREATE TABLE knowledge_bases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL
        REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_kb_org UNIQUE (id, organization_id)
);

CREATE TABLE documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL,
    knowledge_base_id UUID NOT NULL,
    uploaded_by UUID REFERENCES users(id) ON DELETE SET NULL,
    filename VARCHAR(500) NOT NULL,
    object_key VARCHAR(1000) NOT NULL,
    mime_type VARCHAR(255),
    checksum VARCHAR(128),
    version INTEGER NOT NULL DEFAULT 1 CHECK (version > 0),
    status VARCHAR(30) NOT NULL DEFAULT 'UPLOADED'
        CHECK (status IN (
            'UPLOADED', 'PROCESSING', 'READY',
            'FAILED', 'ARCHIVED', 'DELETED'
        )),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT fk_document_kb_org
        FOREIGN KEY (knowledge_base_id, organization_id)
        REFERENCES knowledge_bases(id, organization_id),
    CONSTRAINT uq_document_id_org UNIQUE (id, organization_id)
);

CREATE INDEX idx_members_user
    ON organization_members(user_id);

CREATE INDEX idx_kb_org
    ON knowledge_bases(organization_id);

CREATE INDEX idx_documents_org
    ON documents(organization_id);

CREATE INDEX idx_documents_kb
    ON documents(knowledge_base_id);

CREATE INDEX idx_documents_status_created
    ON documents(status, created_at DESC);
