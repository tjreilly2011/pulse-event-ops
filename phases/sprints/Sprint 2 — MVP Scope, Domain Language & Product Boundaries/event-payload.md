# Event Payload

**Sprint**: Sprint 2 — MVP Core Model, Domain Language & Product Boundaries  
**Phase**: PHASE 0 — Discovery & Product Definition  
**Date**: 2026-04-19  

---

## Design Principles

- **Mobile-first**: Every required field must be completable on a mobile device under pressure in under 10 seconds
- **Minimal by default**: If a field is not needed to route, acknowledge, or resolve an event, it is optional or deferred
- **Generic core, vertical extension**: Core fields apply to all event types. Vertical-specific metadata is in a separate payload envelope
- **No schema here**: This document defines the logical model. Actual DB columns and API request shapes are designed in the implementation sprint.

---

## Payload Structure

```
Event
├── Core Fields (required — all event types)
├── Optional Core Fields
└── Vertical Metadata (required or optional per event type)
    └── Rail: passenger_assistance
    └── Rail: service_issue
    └── Rail: onboard_incident
```

---

## Core Fields (Required — All Events)

These fields must be present on every event regardless of type or vertical.

| Field | Type | Source | Description |
|---|---|---|---|
| `id` | UUID | Platform (generated) | Unique event identifier |
| `event_type` | string | Creator selects | Type identifier from the vertical's type registry |
| `status` | enum | Platform | Current lifecycle state |
| `created_by` | actor_id | Platform (from session) | The actor who submitted the event |
| `created_at` | UTC timestamp | Platform (generated) | When the event was submitted |
| `updated_at` | UTC timestamp | Platform (updated on transition) | When the event was last modified |
| `destination_location_id` | location_id | Creator selects | Where the event needs to be routed to |

> `destination_location_id` is core because routing depends on it. The platform needs to know where to send the event regardless of vertical.

---

## Optional Core Fields

These fields are available to all event types but are not required.

| Field | Type | Source | Description |
|---|---|---|---|
| `title` | string | Creator (or platform-derived) | Human-readable summary. If omitted, derived from event type. |
| `description` | string | Creator | Free text context |
| `priority` | enum: `normal`, `high`, `critical` | Creator | Defaults to `normal` if not set |
| `source_location_id` | location_id | Creator / platform | Where the event originated (e.g. train position) |

---

## Vertical Metadata

Vertical-specific fields are enclosed in a typed metadata envelope. The platform core stores and forwards this envelope without interpreting it. Each vertical defines its own required and optional fields.

---

### Rail Vertical — `passenger_assistance`

**Vertical**: `rail`  
**Event type**: `passenger_assistance`

#### Required

| Field | Type | Source | Description |
|---|---|---|---|
| `assistance_type` | enum | Creator selects | `wheelchair_ramp`, `boarding_assistance`, `other` |
| `coach_number` | string | Creator enters | Coach or carriage identifier on the train |

#### Optional

| Field | Type | Source | Description |
|---|---|---|---|
| `train_service_id` | string | Creator / schedule integration | Train service or run number. Deferred — schedule integration not in MVP. |
| `notes` | string | Creator | Additional context for the receiving station |
| `passenger_count` | integer | Creator | Number of passengers requiring assistance |

---

### Rail Vertical — `service_issue`

**Vertical**: `rail`  
**Event type**: `service_issue`

#### Required

| Field | Type | Source | Description |
|---|---|---|---|
| `issue_type` | enum | Creator selects | `aircon_failure`, `no_water`, `facility_closed`, `other` |

#### Optional

| Field | Type | Source | Description |
|---|---|---|---|
| `affected_coaches` | string | Creator | Which coaches are affected |
| `train_service_id` | string | Creator | Train service reference |
| `notes` | string | Creator | Free text detail |

---

### Rail Vertical — `onboard_incident`

**Vertical**: `rail`  
**Event type**: `onboard_incident`

#### Required

| Field | Type | Source | Description |
|---|---|---|---|
| `incident_type` | enum | Creator selects | `medical`, `security`, `altercation`, `other` |
| `location_on_train` | string | Creator | Coach or position on the train |

#### Optional

| Field | Type | Source | Description |
|---|---|---|---|
| `emergency_services_called` | boolean | Creator | Whether 999/112 has been called |
| `train_service_id` | string | Creator | Train service reference |
| `notes` | string | Creator | Free text |

> **Note**: `onboard_incident` events of type `medical` or `security` should default `priority` to `critical`. This logic belongs in the vertical rules layer, not the platform core.

---

## What Is Explicitly Excluded from MVP Payload

| Field | Reason deferred |
|---|---|
| `assigned_to` | Explicit assignment deferred — acknowledgment serves as implicit assignment |
| `schedule_data` | Schedule/timetable integration is post-MVP |
| `passenger_identity` | GDPR/privacy concern — not needed for workflow routing |
| `geolocation (GPS)` | MVP routing targets station-based staff via `destination_location_id`. Routing to train-based staff (guards, supervisors on other services) requires live position data — adds significant complexity; deferred pending clearer routing requirements for that recipient type |
| `attachments / photos` | Adds mobile UX complexity; deferred |
| `severity SLA timers` | Operational rules layer — deferred |
| `tags / labels` | Analytics/filtering layer — deferred |

---

## Field Immutability Rules

| Field | Mutable after creation? |
|---|---|
| `id` | Never |
| `event_type` | Never |
| `created_by` | Never |
| `created_at` | Never |
| `status` | Via explicit lifecycle transition only |
| `updated_at` | Updated automatically on any change |
| `destination_location_id` | No (MVP). Possible future: management/control can reroute |
| `priority` | Yes — creator or management/control may update |
| Vertical metadata | No — append additional context via event update instead |
