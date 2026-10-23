package com.example.platform.membership;

import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

public interface OrganizationMemberRepository extends JpaRepository<OrganizationMember, UUID> {

    Optional<OrganizationMember> findByOrganizationIdAndUserIdAndStatus(
        UUID organizationId,
        UUID userId,
        MembershipStatus status
    );
}
