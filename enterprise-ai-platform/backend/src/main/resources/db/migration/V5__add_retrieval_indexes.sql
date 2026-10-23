
CREATE INDEX idx_chunks_embedding_hnsw
ON document_chunks
USING hnsw (embedding vector_cosine_ops)
WHERE embedding IS NOT NULL;

CREATE INDEX idx_chunks_content_fts
ON document_chunks
USING gin (to_tsvector('english', content));
