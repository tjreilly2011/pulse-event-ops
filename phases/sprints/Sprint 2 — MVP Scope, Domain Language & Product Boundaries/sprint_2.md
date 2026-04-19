# Sprint 2 — MVP Scope, Domain Language & Product Boundaries

## Phase
PHASE 0 — Discovery & Product Definition

## Goal
Define the MVP product boundary, core domain language, and the initial event/workflow model.

## Why This Sprint Matters
We need a shared vocabulary before implementation begins. The system should be generic at the core while still serving the rail MVP clearly. This sprint creates the language and boundaries that the rest of the architecture will rely on.

## Wishlist
- Define the MVP domain vocabulary:
  - event
  - incident
  - update
  - location
  - reporter
  - assignee
  - queue
  - status
- Define the initial event lifecycle states
- Define the minimum event payload required for MVP
- Define the MVP permissions model at a high level
- Define the MVP notification triggers at a high level
- Define what is explicitly not included in MVP
- Produce a product boundary document

## Constraints
- Keep lifecycle simple
- Keep payload minimal and mobile-first
- Avoid rail-specific logic leaking into generic core concepts

## Out of Scope
- Full DB schema
- Full auth implementation
- Complex analytics
- AI / prediction features

## Success Criteria
- Domain language is documented
- Event lifecycle is agreed
- MVP boundaries are explicit
- Non-goals are documented

## Notes
This sprint should make later architecture and DB design much easier.