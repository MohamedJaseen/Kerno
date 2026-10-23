ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE documents FORCE ROW LEVEL SECURITY;

CREATE POLICY documents_tenant_isolation
ON documents
FOR ALL
USING (
    organization_id =
    NULLIF(
        current_setting('app.current_org_id', true),
        ''
    )::UUID
)
WITH CHECK (
    organization_id =
    NULLIF(
        current_setting('app.current_org_id', true),
        ''
    )::UUID
);
