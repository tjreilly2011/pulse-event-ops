# Domain Language

**Sprint**: Sprint 2 — MVP Core Model, Domain Language & Product Boundaries  
**Phase**: PHASE 0 — Discovery & Product Definition  
**Date**: 2026-04-19  

---

## Purpose

This document defines the shared vocabulary for the platform. Every concept here has a precise meaning that will be used consistently in code, API contracts, documentation, and conversations.

If a term is not defined here, it should not be used as a domain concept until it is added.

---

## Core Vocabulary

### Event

The primary object in the platform.

An **event** is a structured record of something that happened, is happening, or needs to happen in an operational context. It has a type, a lifecycle, a payload, an actor who created it, and a complete audit trail.

Events are first-class objects. Everything else in the platform exists to support the lifecycle and visibility of events.

**An event is NOT a log entry, a message, or a chat.** It is a structured operational record with defined states, responsible actors, and a clear outcome.

---

### Event Update

An **event update** is additional information appended to an existing event after it was created.

An event update does not change the event type or reset the lifecycle. It extends the event timeline with new context — a note from the creator, a status elaboration from the responder, or a system-generated observation.

All updates are persisted as part of the event's timeline.

---

### Location

A **location** is a named operational position relevant to an event.

In the platform core, a location is abstract: it has an identifier, a name, and a type. The platform does not hardcode what a location means.

In the rail vertical:
- A location is typically a **station** or **platform**
- The train's current or destination position may also be a location
- Rail-specific location types are defined in the vertical configuration layer, not the platform core

---

### Actor

An **actor** is any party that takes a meaningful action within the platform.

Actors are typically human users — a guard, a station staff member, an operations controller. The platform itself can also act as an actor for system-generated transitions (e.g. marking an event as `DELIVERED` automatically after routing).

Every state transition and update in a timeline is attributed to an actor.

---

### Role

A **role** is a named set of capabilities. Every actor is assigned one role. The role determines what the actor can create, receive, acknowledge, update, resolve, view, and cancel.

Platform roles are generic. Vertical-specific job titles map to platform roles — they do not replace them.

See `role-model.md` for the full role and permissions definition.

---

### Assignment

**Assignment is implicit at MVP.**

When an actor acknowledges an event, they are implicitly taking ownership of responding to it. This is recorded in the event timeline with actor identity and timestamp.

No explicit assignment step exists in the MVP workflow. The acknowledgment action serves as both receipt confirmation and implicit self-assignment.

> **Future**: Explicit assignment (to an individual or a team) may be introduced in a later version when the workflow requires it. The data model should be designed to support this without requiring it in MVP.

---

### Status

**Status** is the current lifecycle state of an event. It transitions in one direction through a defined set of states.

Status represents the operational truth of an event at a point in time — not an opinion or a label, but a precise machine-readable state.

The full lifecycle and valid transitions are defined in `event-lifecycle.md`.

---

### Acknowledgment

An **acknowledgment** is a deliberate action by a receiving actor confirming that:
1. They have received the event
2. They understand what is being asked
3. They are taking responsibility for responding

An acknowledgment records:
- The actor who acknowledged
- The timestamp of acknowledgment
- An optional short note from the acknowledging actor

Acknowledgment transitions the event from `DELIVERED` → `ACKNOWLEDGED` and implicitly assigns the event to the acknowledging actor.

An unacknowledged event that has been delivered is a visible signal to operations/control that coordination may be failing.

---

### Notification

A **notification** is a message sent by the platform to alert an actor of an event or status change.

Notifications are outbound signals triggered by lifecycle transitions. They are not the event itself — they are a prompt to look at the event.

At MVP, notifications are push notifications to mobile devices and/or in-app alerts.

The triggers that produce notifications are defined in `notification-triggers.md`.

---

## Platform Core vs Rail Vertical Boundary

This boundary is critical. The platform core must remain generic so that future verticals can be added without modifying core logic.

### Platform Core Concepts

These concepts exist in the platform core and apply to every vertical:

| Concept | Defined in core? |
|---|---|
| Event | ✅ |
| Event Update | ✅ |
| Location (abstract) | ✅ |
| Actor | ✅ |
| Role | ✅ |
| Assignment (implicit) | ✅ |
| Status | ✅ |
| Acknowledgment | ✅ |
| Notification | ✅ |
| Timeline / Audit trail | ✅ |

### Rail Vertical Layer

These concepts are rail-specific and belong in the vertical configuration or extension layer, not the platform core:

| Concept | Belongs in rail vertical |
|---|---|
| Event types: `passenger_assistance`, `onboard_incident`, `service_issue` | ✅ |
| Assistance subtypes: `wheelchair_ramp`, `boarding_assistance` | ✅ |
| Location types: `station`, `platform`, `train_position` | ✅ |
| Role labels: `guard`, `CSO`, `station staff`, `ops controller` | ✅ |
| Train / service identifiers | ✅ |
| Coach / carriage numbers | ✅ |
| Route / timetable references | ✅ |

### The Rule

> If a concept only makes sense because of trains, it belongs in the rail vertical layer.  
> If a concept would apply equally in a venue, a logistics depot, or an airport, it belongs in the platform core.

This separation must be preserved from the first line of code written.
