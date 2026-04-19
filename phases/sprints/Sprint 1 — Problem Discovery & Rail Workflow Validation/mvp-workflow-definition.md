# MVP Workflow Definition

**Sprint**: Sprint 1 — Problem Discovery & Rail Workflow Validation  
**Phase**: PHASE 0 — Discovery & Product Definition  
**Date**: 2026-04-19  

---

## Selected MVP Use Case

**Passenger Assistance Coordination — Wheelchair Ramp Request**

A guard creates a structured assistance request on mobile. Station staff receive and acknowledge it. Operations see it in real time. A full audit trail is persisted.

---

## Why This Was Selected

| Criterion | Assessment |
|---|---|
| Frequency | High — happens multiple times per day |
| Clarity | Single, discrete workflow — no ambiguity |
| Value | Directly removes the core failure mode (no answer, no record) |
| Scope | Contained — two roles, one event, one acknowledgment |
| Risk | Low — not life-safety; no emergency protocols required |
| Generalisability | The workflow pattern applies to all coordination scenarios |

This scenario is the cleanest possible first proof of the platform. If this works for a real guard on a real train, the foundation is validated for every more complex scenario thereafter.

---

## The MVP Workflow

### Actors

| Actor | Role | Device |
|---|---|---|
| Guard / CSO | Creates the event | Mobile app (Flutter) |
| Station Staff | Receives and acknowledges | Mobile app or simple web |
| Operations / Control | Observes | Ops dashboard (HTMX) |

---

### Event Lifecycle

```
CREATED → DELIVERED → ACKNOWLEDGED → RESOLVED
```

| State | Triggered by | Meaning |
|---|---|---|
| `CREATED` | Guard submits event | Request exists and is recorded |
| `DELIVERED` | Platform routes to station | Station staff have been notified |
| `ACKNOWLEDGED` | Station staff taps confirm | Station will have ramp ready |
| `RESOLVED` | Staff marks complete (optional MVP) | Assistance was provided |

---

### Step-by-Step Workflow

**Step 1 — Guard creates event**
- Actor: Guard
- Trigger: Passenger informs guard of need, or guard observes it
- Action: Opens app → selects "Passenger Assistance" → enters: coach, need type, destination
- Output: Event record created with status `CREATED`
- Time expected: < 10 seconds

**Step 2 — Event delivered to station**
- Actor: Platform (automatic)
- Trigger: Event creation
- Action: Route event to station staff at destination
- Delivery: Push notification + in-app alert
- Output: Event status updated to `DELIVERED`
- Time expected: Near-instant

**Step 3 — Station staff acknowledge**
- Actor: Station staff
- Trigger: Notification received
- Action: Taps "Acknowledge" or "Ramp will be ready"
- Output: Event status updated to `ACKNOWLEDGED`, timestamped
- Guard receives update on mobile
- Time expected: Within 2 minutes of receipt

**Step 4 — Guard sees acknowledgment**
- Actor: Guard (passive)
- Trigger: Platform updates mobile in real time
- Action: None required — device updates automatically
- Output: Guard has confirmed awareness, can focus on other duties

**Step 5 — Assistance provided, event resolved**
- Actor: Station staff
- Trigger: Passenger disembarks with assistance
- Action: Taps "Resolved" (optional at MVP)
- Output: Event status updated to `RESOLVED`, timestamped
- Full lifecycle record now complete

---

### Failure Handling

| Failure Mode | Platform Response |
|---|---|
| Station staff do not acknowledge | Event stays `DELIVERED`, flagged as unacknowledged on ops dashboard |
| Guard device offline when creating | Event queued locally and submitted when connection restored |
| Station device offline | Notification retried, visible on ops dashboard |

---

## Minimum Viable Inputs (Event Payload)

| Field | Required | Source |
|---|---|---|
| Event type | Yes | Selected from list (e.g. "Passenger Assistance") |
| Coach / carriage number | Yes | Guard enters |
| Assistance need | Yes | Selected from list (e.g. "Wheelchair ramp") |
| Destination station | Yes | Guard confirms (pre-populated from schedule if available) |
| Free text note | No | Optional guard note |
| Created by (user) | Yes | Platform — authenticated guard session |
| Created at (timestamp) | Yes | Platform — auto |
| Train / service ID | Future | Schedule integration deferred |

---

## What This Proves

If this workflow functions end-to-end on a real device with real users:

1. The mobile event creation UX works under pressure
2. The routing model correctly targets the right station
3. The acknowledgment loop closes the communication gap
4. The audit trail records are reliable and complete
5. The ops dashboard provides real-time situational awareness

Every subsequent use case — medical incidents, service issues, engineering faults — reuses this exact pattern. The guard always creates. The right party always receives. Ops always sees. Everything is recorded.

---

## Feed into Sprint 2

The following decisions are explicitly deferred to Sprint 2:

- Domain model definition (event, incident, update, location, reporter, assignee)
- Event lifecycle formalisation (states, transitions, guards)
- Permissions model (who can see/create/acknowledge which event types)
- Notification trigger rules
- MVP payload schema
- Product boundary document (what is and is not in scope for MVP implementation)
