# Notification Triggers

**Sprint**: Sprint 2 — MVP Core Model, Domain Language & Product Boundaries  
**Phase**: PHASE 0 — Discovery & Product Definition  
**Date**: 2026-04-19  

---

## Design Principles

- Notifications are triggered by lifecycle events, not by polling
- Each trigger has a defined recipient set
- Notifications must not substitute for the audit trail — they are prompts, not records
- At MVP, delivery is push notification to mobile + in-app alert
- Email and SMS are deferred

---

## MVP Notification Triggers

### NT-01 — Event Created (Routing Notification)

**Trigger**: Event transitions to `DELIVERED`  
**Recipient**: `support_role` actors at the `destination_location`  
**Channel**: Push notification + in-app alert  

**Payload to include**:
- Event type (human-readable label)
- Creator role (e.g. "Guard")
- Destination location name
- Priority
- Key vertical metadata (e.g. coach number, assistance type)
- Estimated arrival time if available (deferred — schedule integration)

**Purpose**: Give station staff advance notice in time to act.

---

### NT-02 — Event Acknowledged

**Trigger**: Event transitions to `ACKNOWLEDGED`  
**Recipient**: Event creator (`frontline_operator`)  
**Channel**: Push notification + in-app update  

**Payload to include**:
- Confirmation that the event was acknowledged
- Name/role of acknowledging actor (if available)
- Timestamp of acknowledgment
- Optional note from acknowledging actor

**Purpose**: Close the confirmation loop for the guard — they no longer need to chase.

---

### NT-03 — Status Changed

**Trigger**: Event transitions to `IN_PROGRESS`, `RESOLVED`, or `CANCELLED`  
**Recipient**: Event creator + `management_control`  
**Channel**: Push notification + in-app update  

**Payload to include**:
- New status
- Actor who triggered the transition
- Timestamp
- Optional note attached to the transition

**Purpose**: Keep the creator informed of progress without requiring them to check manually. Keep ops/control updated.

---

### NT-04 — Event Unacknowledged (Timeout Warning)

**Trigger**: Event has been `DELIVERED` but not `ACKNOWLEDGED` within a defined threshold  
**Recipient**: `management_control`  
**Channel**: In-app alert on ops dashboard + push notification  

**Threshold**: Configurable per event type. Default: 3 minutes. (Exact value to be confirmed during implementation.)

**Payload to include**:
- Event identifier and type
- Creator and destination
- How long since delivery
- Priority

**Purpose**: Give operations/control early warning of a coordination failure so they can intervene before the train arrives.

---

### NT-05 — Critical Priority Event Created

**Trigger**: Any event with `priority: critical` transitions to `DELIVERED`  
**Recipient**: `management_control` (in addition to NT-01 recipient)  
**Channel**: Push notification  

**Purpose**: Ensure ops/control is immediately aware of high-severity events, regardless of whether they are actively monitoring the dashboard.

---

## Out of Scope for MVP Notifications

| Capability | Rationale |
|---|---|
| Email notifications | Deferred |
| SMS notifications | Deferred |
| Digest / summary notifications | Analytics layer — deferred |
| Custom notification rules per actor | Deferred — too complex for MVP |
| Notification preferences / opt-out | Deferred — all MVP notifications are required |
| Scheduled / time-based reminders | Deferred |
| External webhook delivery | Deferred |
| Passenger-facing notifications | Out of scope — no public-facing interface at MVP |

---

## Notification Implementation Notes

> These are guidance for the implementation sprint, not design decisions made here.

- The notification layer must be decoupled from the event lifecycle engine — a notification failure must never block a lifecycle transition
- Notification delivery status should be logged but is not part of the event audit trail
- At MVP, push is via a standard push notification service (FCM/APNs) — no custom infrastructure
- The ops dashboard updates via SSE — it does not require push notifications
