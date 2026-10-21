CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL
        REFERENCES organizations(id) ON DELETE RESTRICT,
    actor_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(150) NOT NULL,
    resource_type VARCHAR(100) NOT NULL,
    resource_id UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE usage_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL
        REFERENCES organizations(id) ON DELETE RESTRICT,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    operation VARCHAR(100) NOT NULL,
    input_tokens BIGINT NOT NULL DEFAULT 0
        CHECK (input_tokens >= 0),
    output_tokens BIGINT NOT NULL DEFAULT 0
        CHECK (output_tokens >= 0),
    estimated_cost NUMERIC(14, 6) NOT NULL DEFAULT 0
        CHECK (estimated_cost >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_audit_org_created
    ON audit_logs(organization_id, created_at DESC);

CREATE INDEX idx_audit_actor_created
    ON audit_logs(actor_id, created_at DESC);

CREATE INDEX idx_usage_org_created
    ON usage_records(organization_id, created_at DESC);

CREATE INDEX idx_usage_user_created
    ON usage_records(user_id, created_at DESC);
