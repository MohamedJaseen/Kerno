package com.example.platform.document;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.access.AccessDeniedException;

import com.example.platform.security.OrganizationAccessService;

@ExtendWith(MockitoExtension.class)
class DocumentAccessServiceTest {

    @Mock
    private DocumentRepository documents;

    @Mock
    private OrganizationAccessService organizationAccess;

    @InjectMocks
    private DocumentAccessService service;

    @Test
    void getDocumentReturnsDocumentWhenMembershipAndDocMatch() {
        UUID organizationId = UUID.randomUUID();
        UUID userId = UUID.randomUUID();
        UUID documentId = UUID.randomUUID();
        Document document = new Document();
        document.setOrganizationId(organizationId);
        document.setKnowledgeBaseId(UUID.randomUUID());
        document.setFilename("alpha.pdf");
        document.setObjectKey("key/alpha.pdf");
        document.setVersion(1);
        document.setStatus("READY");

        when(documents.findByOrganizationIdAndId(organizationId, documentId)).thenReturn(Optional.of(document));

        assertEquals(document, service.getDocument(organizationId, userId, documentId));
        verify(organizationAccess).requireActiveMembership(organizationId, userId);
    }

    @Test
    void getDocumentThrowsWhenDocumentBelongsToAnotherOrganization() {
        UUID organizationId = UUID.randomUUID();
        UUID userId = UUID.randomUUID();
        UUID documentId = UUID.randomUUID();

        when(documents.findByOrganizationIdAndId(organizationId, documentId)).thenReturn(Optional.empty());

        assertThrows(AccessDeniedException.class, () -> service.getDocument(organizationId, userId, documentId));
    }
}
