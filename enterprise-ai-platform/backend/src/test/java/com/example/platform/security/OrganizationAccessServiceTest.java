package com.example.platform.security;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.when;

import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.access.AccessDeniedException;

import com.example.platform.membership.MembershipStatus;
import com.example.platform.membership.OrganizationMember;
import com.example.platform.membership.OrganizationMemberRepository;

@ExtendWith(MockitoExtension.class)
class OrganizationAccessServiceTest {

    @Mock
    private OrganizationMemberRepository memberships;

    @InjectMocks
    private OrganizationAccessService service;

    @Test
    void requireActiveMembershipReturnsMemberWhenUserIsActive() {
        UUID organizationId = UUID.randomUUID();
        UUID userId = UUID.randomUUID();
        OrganizationMember member = new OrganizationMember();
        member.setOrganizationId(organizationId);
        member.setUserId(userId);
        member.setStatus(MembershipStatus.ACTIVE);

        when(memberships.findByOrganizationIdAndUserIdAndStatus(organizationId, userId, MembershipStatus.ACTIVE))
            .thenReturn(Optional.of(member));

        assertEquals(member, service.requireActiveMembership(organizationId, userId));
    }

    @Test
    void requireActiveMembershipThrowsWhenUserHasNoActiveMembership() {
        UUID organizationId = UUID.randomUUID();
        UUID userId = UUID.randomUUID();

        when(memberships.findByOrganizationIdAndUserIdAndStatus(organizationId, userId, MembershipStatus.ACTIVE))
            .thenReturn(Optional.empty());

        assertThrows(AccessDeniedException.class, () -> service.requireActiveMembership(organizationId, userId));
    }
}
