# User Roles

**Sprint**: Sprint 1 — Problem Discovery & Rail Workflow Validation  
**Phase**: PHASE 0 — Discovery & Product Definition  
**Date**: 2026-04-19  

---

## Overview

Three primary roles are involved in the MVP workflow. They operate in different environments, under different pressures, and need different things from the platform.

---

## Role 1: Guard / CSO (Customer Service Operative)

**Type**: Frontline creator  
**Mobility**: Moving — travels with the train  
**Environment**: High pressure, often alone, intermittent connectivity, time-critical  

### Responsibilities
- Passenger welfare onboard
- Safety and compliance
- Door management
- Coordination with stations ahead of arrival
- Reporting onboard incidents and service issues

### Pain Points
- No structured way to notify stations of time-sensitive needs
- Must use phone calls that frequently go unanswered
- No confirmation that requests are received or acted on
- Pulled away from passenger duties to manage unresolved communication
- No record of attempts or outcomes

### What They Need from the Platform
- A fast, low-friction way to create a structured event report (seconds, not minutes)
- Confidence that the right people received it
- Visibility of acknowledgment without needing to chase
- Works on mobile under pressure with degraded connectivity

---

## Role 2: Station Staff

**Type**: Frontline recipient  
**Mobility**: Fixed — at station  
**Environment**: Platform activity, passenger-facing, reactive  

### Responsibilities
- Platform safety
- Passenger assistance (ramps, boarding, mobility)
- Station operations
- Responding to requests from trains

### Pain Points
- No advance warning of incoming requests
- Phone calls arrive without context or structure
- Cannot easily confirm to the train that they've received and will act
- Blindsided when trains arrive with unmet needs

### What They Need from the Platform
- Clear, structured notification of incoming requests before the train arrives
- Simple one-tap acknowledgment to confirm they are preparing
- Enough lead time to act (the event arrives early in the journey, not at the platform)

---

## Role 3: Operations / Control

**Type**: Oversight  
**Mobility**: Fixed — control room or desk  
**Environment**: Multi-train visibility, reactive escalation, reporting  

### Responsibilities
- Network-wide operational visibility
- Incident management and escalation
- Communication with frontline and management
- Reporting and post-incident review

### Pain Points
- No real-time visibility of frontline communication
- Learns about failures after the fact
- Calls frontline staff for updates, adding to their workload
- No single source of truth for live operational state

### What They Need from the Platform
- Live dashboard showing all active events across the network
- Status of each event (reported → acknowledged → resolved)
- No need to call frontline for updates
- Ability to escalate or flag if events are unacknowledged

---

## Role Summary Table

| Role | Environment | Creates Events | Receives Events | Sees Dashboard |
|---|---|---|---|---|
| Guard / CSO | Mobile / Train | Yes (primary) | No | No (MVP) |
| Station Staff | Fixed / Platform | No | Yes | No (MVP) |
| Operations / Control | Fixed / Office | No | Escalations only | Yes |

---

## Out of Scope for MVP

- Passengers directly (no public-facing interface)
- Engineers / maintenance teams (informed via dashboard later, not MVP)
- Management reporting (analytics layer deferred)
- Authentication / permissions detail (deferred to Sprint 2)
