package com.example.platform.document;

import java.util.UUID;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.platform.security.OrganizationAccessService;

@Service
public class DocumentAccessService {

    private final DocumentRepository documents;
    private final OrganizationAccessService organizationAccess;

    public DocumentAccessService(
        DocumentRepository documents,
        OrganizationAccessService organizationAccess
    ) {
        this.documents = documents;
        this.organizationAccess = organizationAccess;
    }

    @Transactional(readOnly = true)
    public Document getDocument(UUID organizationId, UUID authenticatedUserId, UUID documentId) {
        organizationAccess.requireActiveMembership(organizationId, authenticatedUserId);

        return documents
            .findByOrganizationIdAndId(organizationId, documentId)
            .orElseThrow(() -> new AccessDeniedException("Document not found or access denied"));
    }
}
