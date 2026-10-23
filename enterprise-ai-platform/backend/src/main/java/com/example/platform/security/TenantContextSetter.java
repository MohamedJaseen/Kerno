package com.example.platform.security;

import java.util.UUID;

import jakarta.persistence.EntityManager;

import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

@Component
public class TenantContextSetter {

    private final EntityManager entityManager;

    public TenantContextSetter(EntityManager entityManager) {
        this.entityManager = entityManager;
    }

    @Transactional(propagation = Propagation.MANDATORY)
    public void setTenant(UUID authorizedOrganizationId) {
        entityManager
            .createNativeQuery("SELECT set_config('app.current_org_id', :tenantId, true)")
            .setParameter("tenantId", authorizedOrganizationId.toString())
            .getSingleResult();
    }
}
