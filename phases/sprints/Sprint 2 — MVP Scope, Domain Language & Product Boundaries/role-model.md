# Role Model & Permissions

**Sprint**: Sprint 2 — MVP Core Model, Domain Language & Product Boundaries  
**Phase**: PHASE 0 — Discovery & Product Definition  
**Date**: 2026-04-19  

---

## Design Principles

- Three roles at MVP — no more
- Role names are generic platform terms; job title mappings are vertical-specific
- Permissions are coarse-grained at MVP — detailed ACL deferred
- Every actor has exactly one role
- The platform routes and filters based on role

---

## Platform Roles

### `frontline_operator`

**Platform role**: `frontline_operator`  
**Rail vertical mapping**: Guard / CSO (Customer Service Operative)  
**Environment**: Mobile, in the field, potentially offline  

The primary event creator. Works under time pressure with limited attention available. Needs the minimum viable interaction to create a complete, routable event.

---

### `support_role`

**Platform role**: `support_role`  
**Rail vertical mapping**: Station Staff  
**Environment**: Fixed location, platform-facing  

The primary event recipient. Receives targeted notifications for events routed to their location. Acknowledges and resolves events. Does not typically create events at MVP (future scope).

---

### `management_control`

**Platform role**: `management_control`  
**Rail vertical mapping**: Operations Controller / Control Room Staff  
**Environment**: Fixed desk, multi-event visibility  

The oversight role. Cannot create events at MVP (future scope), but has full visibility of all events across the network. Receives notifications for unacknowledged events and critical priority events. Has authority to cancel any event.

---

## Permissions Matrix

| Action | `frontline_operator` | `support_role` | `management_control` |
|---|---|---|---|
| **Create event** | ✅ | ❌ (MVP) | ❌ (MVP) |
| **View own created events** | ✅ | ✅ | ✅ |
| **View events routed to their location** | ❌ | ✅ | ✅ |
| **View all events across network** | ❌ | ❌ | ✅ |
| **Acknowledge event** | ❌ | ✅ | ✅ (escalation use) |
| **Add update / note to event** | ✅ (own events) | ✅ (assigned events) | ✅ (all events) |
| **Mark event IN_PROGRESS** | ❌ | ✅ | ✅ |
| **Resolve event** | ❌ | ✅ | ✅ |
| **Cancel own event** | ✅ | ❌ | ✅ |
| **Cancel any event** | ❌ | ❌ | ✅ |
| **View ops dashboard** | ❌ | ❌ | ✅ |
| **Receive push notification on creation** | ❌ | ✅ (routed to them) | ✅ (critical / unacked) |
| **Receive acknowledgment notification** | ✅ (own events) | ❌ | ❌ |

---

## Role Assignment Rules

- Every actor must be assigned exactly one role before they can interact with the platform
- Roles are assigned at account creation / onboarding
- An actor cannot change their own role
- Role changes require a management/control actor or system admin (auth implementation deferred)
- At MVP, role assignment is a manual configuration step — no self-service role management

---

## What Is Deferred

| Capability | Rationale |
|---|---|
| `support_role` creating events | Not needed for MVP workflow; deferred |
| `management_control` creating events | Possible in future; deferred |
| Sub-roles or permission groups | Over-engineering for MVP |
| Explicit event assignment to individuals | Deferred — acknowledgment serves as implicit assignment |
| Team-based routing (assign to a team, not a location) | Deferred — location-based routing is sufficient for MVP |
| Detailed ACL / attribute-based access control | Deferred — coarse role-based permissions sufficient |
| Role hierarchy / inheritance | Deferred — three flat roles are sufficient |

---

## Rail Vertical Role Mapping Reference

This mapping belongs in the rail vertical configuration, not the platform core. Included here for clarity.

| Platform role | Rail job title(s) |
|---|---|
| `frontline_operator` | Guard, CSO, Train Manager, Conductor |
| `support_role` | Station Staff, Platform Attendant, Duty Manager |
| `management_control` | Operations Controller, Control Room, Train Operations Manager |
