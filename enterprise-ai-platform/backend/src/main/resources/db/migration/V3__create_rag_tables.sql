CREATE TABLE document_chunks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL,
    document_id UUID NOT NULL,
    chunk_index INTEGER NOT NULL CHECK (chunk_index >= 0),
    content TEXT NOT NULL,
    page_number INTEGER,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    embedding VECTOR(384),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT fk_chunk_document_org
        FOREIGN KEY (document_id, organization_id)
        REFERENCES documents(id, organization_id)
        ON DELETE CASCADE,
    CONSTRAINT uq_document_chunk
        UNIQUE (document_id, chunk_index),
    CONSTRAINT uq_chunk_id_document
        UNIQUE (id, document_id)
);

CREATE TABLE ingestion_jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL,
    document_id UUID NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING'
        CHECK (status IN (
            'PENDING', 'PROCESSING', 'COMPLETED',
            'FAILED', 'CANCELLED'
        )),
    attempt_count INTEGER NOT NULL DEFAULT 0
        CHECK (attempt_count >= 0),
    error_message TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT fk_job_document_org
        FOREIGN KEY (document_id, organization_id)
        REFERENCES documents(id, organization_id)
        ON DELETE CASCADE
);

CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL
        REFERENCES organizations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL
        REFERENCES users(id) ON DELETE RESTRICT,
    title VARCHAR(500),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_conversation_id_org
        UNIQUE (id, organization_id)
);

CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL,
    role VARCHAR(30) NOT NULL
        CHECK (role IN ('SYSTEM', 'USER', 'ASSISTANT', 'TOOL')),
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT fk_message_conversation
        FOREIGN KEY (conversation_id)
        REFERENCES conversations(id) ON DELETE CASCADE
);

CREATE TABLE message_citations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID NOT NULL
        REFERENCES messages(id) ON DELETE CASCADE,
    chunk_id UUID NOT NULL,
    document_id UUID NOT NULL,
    page_number INTEGER,
    relevance_score DOUBLE PRECISION,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT fk_citation_chunk_document
        FOREIGN KEY (chunk_id, document_id)
        REFERENCES document_chunks(id, document_id)
        ON DELETE CASCADE,
    CONSTRAINT uq_message_citation
        UNIQUE (message_id, chunk_id)
);

CREATE INDEX idx_chunks_org_document
    ON document_chunks(organization_id, document_id);

CREATE INDEX idx_jobs_org_status
    ON ingestion_jobs(organization_id, status);

CREATE INDEX idx_jobs_status_created
    ON ingestion_jobs(status, created_at);

CREATE INDEX idx_conversations_org_user
    ON conversations(organization_id, user_id, created_at DESC);

CREATE INDEX idx_messages_conversation_created
    ON messages(conversation_id, created_at);

CREATE INDEX idx_citations_message
    ON message_citations(message_id);

CREATE INDEX idx_citations_document
    ON message_citations(document_id);
