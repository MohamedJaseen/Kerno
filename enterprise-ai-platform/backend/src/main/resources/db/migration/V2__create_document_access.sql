CREATE TABLE document_permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id UUID NOT NULL
        REFERENCES documents(id) ON DELETE CASCADE,
    principal_type VARCHAR(30) NOT NULL
        CHECK (principal_type IN ('USER', 'ORG_ROLE')),
    principal_id VARCHAR(255) NOT NULL,
    permission VARCHAR(30) NOT NULL
        CHECK (permission IN ('READ', 'WRITE', 'ADMIN')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_document_permission
        UNIQUE (document_id, principal_type, principal_id, permission)
);

CREATE INDEX idx_doc_permissions_document
    ON document_permissions(document_id);
