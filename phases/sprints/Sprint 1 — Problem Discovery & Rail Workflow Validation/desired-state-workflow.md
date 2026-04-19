# Desired State Workflow

**Sprint**: Sprint 1 — Problem Discovery & Rail Workflow Validation  
**Phase**: PHASE 0 — Discovery & Product Definition  
**Date**: 2026-04-19  

---

## Focus Scenario: Passenger Wheelchair Assistance

---

## What "Good" Looks Like

The guard creates a structured event report on their mobile in under 10 seconds.  
The right station staff receive it immediately and can acknowledge with a single tap.  
The guard sees the acknowledgment on their device — no chase needed, no uncertainty.  
Operations can see every active event across the network in real time.  
A full record exists regardless of outcome.

No phone call. No repeat attempts. No verbal guesswork. No missing audit trail.

---

## Desired State: What Should Happen

### Step 1 — Guard identifies the need
Guard is informed a passenger requires wheelchair assistance at the next station.

**No change here** — this is a human observation. No technology needed.

---

### Step 2 — Guard creates a structured event on mobile
Guard opens the app. Selects "Passenger Assistance". Fills in:
- Coach number  
- Need type (wheelchair assistance)
- Destination station (pre-populated from schedule if available)
- Optional free text note

Submits in under 10 seconds.

**Tools used**: Mobile app (Flutter).  
**Key requirement**: Fast enough to do while managing the train. Not a form. A structured, minimal input.

---

### Step 3 — Event is routed to destination station
The platform receives the event and routes it to the correct station staff for that destination.

Station staff receive a clear, structured notification on their device or station terminal:
- Train number / arrival time
- Coach number
- Passenger need
- Estimated arrival

**Tools used**: Platform backend, push notification.  
**Key requirement**: Delivered with enough lead time for staff to act.

---

### Step 4 — Station staff acknowledge
Station staff tap "Acknowledged" or "Ramp will be ready".

This acknowledgement:
- Is timestamped
- Is stored as part of the event record
- Is immediately visible to the guard on their device
- Is visible on the operations dashboard

**Tools used**: Station device / app or simple web interface.  
**Key requirement**: One action. Not a workflow. Just confirmation.

---

### Step 5 — Guard sees acknowledgment
Guard's mobile updates to show the station has confirmed.

Guard can now focus on other duties with confidence.

**Tools used**: Mobile app — real-time update.  
**Key requirement**: No polling. No refresh. Event updates appear automatically.

---

### Step 6 — Train arrives, assistance is provided
Station staff have the ramp ready. Passenger disembarks without delay.

Staff marks the event as **Resolved** (optional at MVP, but recorded if done).

**Tools used**: Station device.

---

### Step 7 — Full audit record exists
The platform has stored:
- Time guard created the event
- Event details and payload
- Time station received it
- Time station acknowledged
- Time resolved (if marked)
- All status transitions

Operations/control had full visibility throughout, without calling anyone.

---

## The Desired Workflow Summary

```
Guard identifies need
      ↓
Guard creates event on mobile (< 10 seconds)
      ↓
Event routed to station staff automatically
      ↓
Station staff acknowledge (1 tap)
      ↓
Guard sees acknowledgment on device
      ↓
Train arrives → assistance is ready
      ↓
Full audit record. Ops had visibility throughout.
```

---

## Before vs After

| | Before | After |
|---|---|---|
| How guard notifies station | Phone call (often fails) | Structured event via mobile |
| Guard workload | Repeated call attempts | One action, done |
| Station lead time | Minimal (called just before arrival) | Notified earlier, more preparation time |
| Confirmation | None | Explicit acknowledgment, timestamped |
| Guard certainty | None | Visible acknowledgment on device |
| Operations visibility | None | Real-time dashboard |
| Audit trail | None | Full lifecycle record |
| Failure mode | Silent (no answer = nothing happens) | Visible (unacknowledged = flag on dashboard) |

---

## Design Principles Upheld

- **Mobile-first**: Created on a phone, in seconds, under pressure
- **Deterministic**: The same input always produces the same routing and notification
- **Auditable**: Every state transition is stored
- **Role-appropriate**: Guard creates, station receives, ops observes — each role is separate
- **No AI/LLM**: Pure structured workflow, no interpretation layer
- **Degraded-environment tolerant**: Minimal input, offline-aware (queue and retry if needed)
