# Current State Workflow

**Sprint**: Sprint 1 — Problem Discovery & Rail Workflow Validation  
**Phase**: PHASE 0 — Discovery & Product Definition  
**Date**: 2026-04-19  

---

## Focus Scenario: Passenger Wheelchair Assistance

A passenger onboard requires wheelchair ramp assistance to disembark at their destination station.

This scenario was selected as the MVP focus. It is the highest-frequency, clearest-workflow, most directly solvable coordination gap in daily rail operations.

---

## Current State: What Happens Today

### Step 1 — Guard identifies the need
The guard is informed by the passenger (or notices themselves) that wheelchair ramp assistance will be required at the next station.

**Tools used**: None. Verbal communication with passenger.

---

### Step 2 — Guard attempts to contact the station
The guard must find the station's contact number and place a call. This may be via:
- Internal train phone system
- Personal or work mobile
- Radio (on some networks)

**Tools used**: Phone call / radio.

---

### Step 3 — Waiting for an answer
The guard waits for the station to answer. This may take multiple attempts.

Common outcomes:
- No answer (station is busy, understaffed, or phone is unmanned)
- Partial answer (gets through but no one qualified or able to help answers)
- Successful connection (rare best case)

**Tools used**: Phone.  
**Failure rate**: High. No answer is the most common outcome on busy services.

---

### Step 4 — Verbal communication (if call connects)
The guard verbally explains the need: coach number, passenger requirement, arrival time.

There is no structured format. Information quality depends on the individual guard and the call quality.

**Tools used**: Voice.  
**Failure modes**:
- Misheard information
- No record of what was requested or agreed
- Station staff may tell guard "we'll do our best" with no firm commitment

---

### Step 5 — No confirmation
The guard has no way to confirm that the station staff:
- Heard the request clearly
- Will actually prepare the ramp
- Are available to assist at the platform

The guard must proceed with the train regardless and hope the assistance is ready.

**Tools used**: None.  
**Outcome**: Uncertainty.

---

### Step 6 — Train arrives
One of three outcomes:
1. ✅ Ramp is ready, assistance is provided — happened to work
2. ⚠️ Staff are on platform but unprepared — delay while ramp is retrieved
3. ❌ No staff present — passenger cannot disembark, significant delay

**Tools used**: None.  
**Audit trail**: None.

---

### Step 7 — No record, no learning
Regardless of outcome, there is no record of:
- The request being made
- How many attempts were needed
- Whether assistance was provided
- How long the passenger waited
- What the outcome was

Operations/control has no visibility at any point in this workflow.

---

## The Broken Workflow Summary

```
Guard identifies need
      ↓
Guard calls station (often fails to connect)
      ↓
Verbal request with no structure or record
      ↓
No acknowledgment. No confirmation.
      ↓
Guard proceeds with no certainty.
      ↓
Train arrives → outcome is random.
      ↓
No audit trail. No improvement. Repeat tomorrow.
```

---

## Friction Point Summary

| Point | Friction | Impact |
|---|---|---|
| Finding station contact | Guard must know / look up number | Delays the attempt |
| Getting through | High no-answer rate | Request never made |
| No structured format | Information lost or misunderstood | Wrong or incomplete action |
| No confirmation | Guard has no certainty | Stress, can't focus on other duties |
| No visibility | Ops cannot see what's happening | Reactive only |
| No record | No audit trail | No accountability, no improvement |

---

## Other Scenarios Captured (Not MVP Focus)

### Scenario 2 — Onboard Medical Emergency (Passenger Collapse)
- Guard managing emergency while receiving management calls asking for updates
- Same information relayed multiple times, inconsistently
- Management has no real-time visibility
- Guard is split between the emergency and communication duties

### Scenario 3 — Service Issue (Aircon / No Water / Shop Closed)
- No consistent reporting channel
- Engineers not informed in time
- No status tracking (reported → acknowledged → resolved)
- Management calls for updates, adding to guard workload
- Passengers not informed proactively
