# Problem Statement

**Sprint**: Sprint 1 — Problem Discovery & Rail Workflow Validation  
**Phase**: PHASE 0 — Discovery & Product Definition  
**Date**: 2026-04-19  

---

## The Problem

Rail operations staff have no structured way to communicate time-sensitive operational needs between a moving train and a receiving station.

The only available channels are phone calls. Phone calls go unanswered. When they do connect, there is no record of what was agreed, no confirmation that the receiving party will act, and no way for anyone else to see that the need exists.

This is not an edge case caused by individual carelessness. It is a structural gap. The tools do not exist for this type of communication.

---

## The Most Common Failure

**A guard identifies a passenger who needs wheelchair ramp assistance at the next station.**

The guard must:
- Stop what they are doing
- Find the station's phone number
- Try to call — potentially multiple times
- Hope someone answers before the train arrives
- Receive no confirmation that assistance will actually be ready

If no one answers: no assistance is prepared. The passenger waits on the train. The guard has failed to support the passenger through no fault of their own.

This happens multiple times per day across the network.

---

## Why This Is Hard to Fix Without a Tool

The guard is:
- Alone on a moving train
- Managing passengers, doors, safety, and compliance simultaneously
- Working in a mobile environment with intermittent connectivity
- Under time pressure — the station is minutes away

The station staff:
- May be dealing with platform activity
- Have no prior warning the call is coming
- Receive no structured request — just a phone call
- Have no way to confirm back to the guard in a way that leaves a record

Operations/control:
- Have no visibility of this coordination happening or failing
- Only find out there was a problem after the fact
- Cannot intervene or assist in real time

---

## The Core Failure Pattern

```
Guard identifies need
        ↓
Guard attempts phone call
        ↓
No answer / partial answer / verbal agreement only
        ↓
No confirmation. No record. No visibility.
        ↓
Assistance may or may not happen.
        ↓
No audit trail. No learning. No improvement.
```

---

## What This Costs

- **Passengers** — left waiting, poor experience, potential distress
- **Guards** — stressed, distracted from other duties, unable to confirm outcomes
- **Station staff** — blindsided, reactive, no advance preparation time
- **Operations** — no live visibility, caught off guard, managing by exception
- **The organisation** — repeated incidents, complaints, no data to act on

---

## The Hypothesis

A structured, mobile-first event reporting tool — designed for the frontline, not the desk — can replace the phone call loop with a simple, logged, acknowledged workflow.

The guard creates a structured event in seconds.  
The station receives it immediately and can acknowledge.  
The guard sees the acknowledgment.  
Operations see everything in real time.  
A record exists regardless of outcome.

This eliminates the core failure mode without requiring anyone to change their role or learn a complex system.
