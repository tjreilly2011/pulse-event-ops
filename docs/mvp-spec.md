# MVP Specification

## Multi-Role Interaction Model

The system supports multiple role types:

- frontline operators (field-based users executing work)
- management/control (users overseeing operations and coordinating responses)
- specialists (engineers, contractors, emergency responders, or other support roles)

All roles can:
- view relevant events based on scope and permissions
- interact with events through structured actions
- contribute updates, status changes, and structured notes

---

## Interaction Principle

Users do not communicate via free-form messaging.

Instead:
- all interaction happens within the context of an event
- events act as the coordination layer between roles
- communication is structured, visible, and auditable

This ensures:
- no loss of context
- no fragmented communication
- no reliance on external messaging tools

---

## Role-Based Participation

- Frontline operators:
  - create events
  - update events
  - provide real-time context from the field

- Management/control:
  - monitor all relevant events
  - filter and prioritize operational activity
  - intervene or issue structured updates when necessary

- Specialists:
  - are assigned or subscribe to relevant events
  - provide updates, actions, and resolutions within the event context

---

## Event-Centric Coordination

The event is the primary unit of coordination.

Each event must:
- represent a real operational situation
- have a clear lifecycle (e.g. created → acknowledged → in progress → resolved)
- have ownership (individual, team, or role)
- maintain a full timeline of updates and actions

All coordination, updates, and decisions must occur through the event.

---

## Vertical-Agnostic Core

The platform core must remain independent of any specific industry.

Core concepts must NOT include:
- industry-specific terminology
- domain-specific workflows hardcoded into logic
- assumptions about specific asset types (e.g. vehicles, facilities, infrastructure)

Instead, the core must operate using generic abstractions:
- event
- location
- actor
- role
- status
- assignment

---

## Vertical Adaptation Layer

Each industry (rail, airports, logistics, emergency services, etc.) will define:

- domain-specific labels (e.g. station, gate, warehouse)
- domain-specific quick actions (e.g. assistance request, incident report)
- domain-specific event categories
- domain-specific UI terminology

These must be implemented outside the core system, as a configuration or presentation layer.

---

## Core Constraint

The platform must remain:

- event-driven (not message-driven)
- structured (not free-form communication)
- auditable (all actions recorded)
- role-aware (permissions enforced)
- extensible (new verticals can be added without rewriting core logic)

---

## MVP Scope Constraint

For MVP:

- focus on a single primary workflow:
  - creating an event
  - notifying relevant roles
  - acknowledging and updating the event
- avoid building:
  - full messaging systems
  - complex routing engines
  - multi-vertical abstractions beyond what is required

The goal is to prove:
- real-time coordination works
- users adopt structured events over ad hoc communication
- operational visibility improves measurably