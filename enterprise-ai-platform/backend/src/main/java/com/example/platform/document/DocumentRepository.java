package com.example.platform.document;

import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

public interface DocumentRepository extends JpaRepository<Document, UUID> {

    Optional<Document> findByOrganizationIdAndId(UUID organizationId, UUID documentId);
}
