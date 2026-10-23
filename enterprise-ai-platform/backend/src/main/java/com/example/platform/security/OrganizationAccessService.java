package com.example.platform.security;

import java.util.UUID;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.platform.membership.MembershipStatus;
import com.example.platform.membership.OrganizationMember;
import com.example.platform.membership.OrganizationMemberRepository;

@Service
public class OrganizationAccessService {

    private final OrganizationMemberRepository memberships;

    public OrganizationAccessService(OrganizationMemberRepository memberships) {
        this.memberships = memberships;
    }

    @Transactional(readOnly = true)
    public OrganizationMember requireActiveMembership(UUID organizationId, UUID userId) {
        return memberships
            .findByOrganizationIdAndUserIdAndStatus(organizationId, userId, MembershipStatus.ACTIVE)
            .orElseThrow(() -> new AccessDeniedException("You do not have access to this organization"));
    }
}
