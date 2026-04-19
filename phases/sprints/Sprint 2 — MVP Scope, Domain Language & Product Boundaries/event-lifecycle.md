# Event Lifecycle

**Sprint**: Sprint 2 — MVP Core Model, Domain Language & Product Boundaries  
**Phase**: PHASE 0 — Discovery & Product Definition  
**Date**: 2026-04-19  

---

## MVP Lifecycle States

The event lifecycle uses the smallest set of states that accurately represents the operational reality of the MVP workflow.

```
CREATED → DELIVERED → ACKNOWLEDGED → RESOLVED
                                   ↘ CANCELLED
                     ↘ CANCELLED
              ↘ CANCELLED
```

```
CREATED → DELIVERED → ACKNOWLEDGED → IN_PROGRESS → RESOLVED
                                                  ↘ CANCELLED
```

> `IN_PROGRESS` is optional at MVP. It exists to support more complex use cases (e.g. a service issue being actively investigated) but is not required for the wheelchair assistance workflow. It must be omitted where it adds no value.

---

## State Definitions

### `CREATED`

The event has been submitted by the creator. It exists in the platform and has a complete, valid payload. It has not yet been routed or delivered.

- **Entered by**: Creator submitting the event
- **Exited by**: Platform routing engine (automatic)

---

### `DELIVERED`

The event has been routed to the correct recipient(s) and a notification has been sent. The event is now awaiting acknowledgment.

- **Entered by**: Platform (automatic, after routing)
- **Exited by**: Recipient actor acknowledging OR actor cancelling

An event that remains `DELIVERED` without acknowledgment is a visible operational signal — it must be surfaced on the ops dashboard as unacknowledged.

---

### `ACKNOWLEDGED`

A responsible actor has confirmed receipt and implicit ownership. Assistance or response is being prepared.

- **Entered by**: Recipient actor (e.g. station staff tapping "Acknowledge")
- **Exited by**: Actor marking resolved, moving to IN_PROGRESS, or cancelling

When an event is acknowledged:
- The acknowledging actor is recorded (with timestamp)
- Implicit self-assignment is recorded in the timeline
- The event creator is notified

---

### `IN_PROGRESS` _(optional at MVP)_

Active work is underway on the event. This state is useful when acknowledgment and active response are meaningfully different steps (e.g. a service fault that takes time to investigate and fix).

- **Entered by**: Acknowledging or managing actor explicitly moving event forward
- **Exited by**: Actor marking resolved or cancelling
- **Skip condition**: For simple acknowledge-and-act workflows (e.g. wheelchair ramp), this state may be skipped entirely.

---

### `RESOLVED`

The event has reached its intended outcome. The operational need has been met.

- **Entered by**: Recipient actor or management/control actor
- **Terminal state**: No further transitions are valid
- **Audit value**: Records who resolved, when, and any final note

---

### `CANCELLED`

The event was invalidated before resolution — the need no longer exists or the event was created in error.

- **Entered by**: Event creator (own events) or management/control actor (any event)
- **Terminal state**: No further transitions are valid
- **Examples**: Passenger left train before reaching destination; event created by mistake
- **Audit value**: Cancellation reason should be recorded

---

## Valid Transitions

| From | To | Triggered by |
|---|---|---|
| `CREATED` | `DELIVERED` | Platform (automatic, after routing) |
| `DELIVERED` | `ACKNOWLEDGED` | Recipient actor |
| `DELIVERED` | `CANCELLED` | Creator or management/control |
| `ACKNOWLEDGED` | `IN_PROGRESS` | Recipient or management/control (optional) |
| `ACKNOWLEDGED` | `RESOLVED` | Recipient or management/control |
| `ACKNOWLEDGED` | `CANCELLED` | Creator or management/control |
| `IN_PROGRESS` | `RESOLVED` | Recipient or management/control |
| `IN_PROGRESS` | `CANCELLED` | Creator or management/control |

Any other transition is invalid and must be rejected by the platform.

---

## Acknowledgment Model

### What counts as acknowledgment

A deliberate actor action — a tap, a click, an API call — that explicitly confirms:
- The event has been received
- The actor understands what is required
- The actor is taking implicit ownership of the response

Acknowledgment is never automatic. It must always be a human action.

### What acknowledgment records

Every acknowledgment persists:
- `acknowledged_by`: actor ID
- `acknowledged_at`: UTC timestamp
- `note`: optional short text from the acknowledging actor

### What acknowledgment does NOT do

- It does not resolve the event
- It does not guarantee the outcome
- It does not remove management/control's visibility

---

## Event Update Model

### What counts as an event update

Any additional information appended to the event timeline after the event was created. Updates do not change the event type, status, or payload — they extend the record.

Types of update:
- **Actor note**: Free text from any participating actor
- **Status transition**: Automatically appended when lifecycle state changes
- **System note**: Platform-generated entry (e.g. "notification sent", "event delivered")

### What must be recorded in the timeline

Every event must maintain a complete, ordered timeline of:

| Entry type | Required fields |
|---|---|
| Status transition | new status, actor (or system), timestamp |
| Acknowledgment | acknowledged_by, timestamp, optional note |
| Actor note / update | author actor, timestamp, text |
| System event | event type, timestamp, details |

The timeline is append-only. No entries are deleted or modified after creation.

---

## Failure Handling

| Failure mode | Behaviour |
|---|---|
| Event not acknowledged within threshold | Flagged as unacknowledged on ops dashboard; management/control notified |
| Delivery fails (recipient offline) | Platform retries; event stays `DELIVERED`; visible on dashboard |
| Event created offline (mobile) | Queued locally; submitted with original `created_at` when connectivity restores |

---

## Design Rule

> The lifecycle must be derivable from stored inputs alone.  
> No state should be inferred, guessed, or reconstructed from side effects.  
> Every transition must be stored at the moment it occurs.
