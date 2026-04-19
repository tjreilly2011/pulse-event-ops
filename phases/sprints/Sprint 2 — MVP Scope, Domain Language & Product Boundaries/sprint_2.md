# Sprint 2 — MVP Core Model, Domain Language & Product Boundaries

## Phase
PHASE 0 — Discovery & Product Definition

## Goal
Define the simplest possible core domain model, MVP boundaries, and event lifecycle needed to support the first rail workflow while keeping the platform generic for future verticals.

## Why This Sprint Matters
Sprint 1 established the real operational pain and the first workflow to solve.

This sprint turns that discovery into a clean product definition that is still pre-implementation, but specific enough to guide the first project/code artifacts and the next architecture/build sprints.

The output of this sprint should make Sprint 3 and beyond straightforward, not speculative.

## Wishlist

- Define the core MVP domain vocabulary:
  - event
  - event update
  - location
  - actor
  - role
  - assignment
  - status
  - acknowledgment
  - notification

- Clarify which concepts belong in the platform core versus the rail vertical layer

- Define the initial event lifecycle states for MVP
  - created
  - acknowledged
  - in_progress
  - resolved
  - cancelled
  - or other minimal agreed set

- Define the minimum event payload required for MVP
  - what must always exist
  - what is optional
  - what is vertical-specific metadata

- Define the minimum role model for MVP
  - frontline operator
  - management/control
  - specialist/support role

- Define MVP permissions at a high level
  - who can create
  - who can acknowledge
  - who can update
  - who can resolve
  - who can view what

- Define the high-level acknowledgment/update model
  - what counts as acknowledgment
  - what counts as an event update
  - what must be recorded in the timeline

- Define the high-level notification triggers for MVP
  - event created
  - event acknowledged
  - status changed
  - important update added

- Define what must remain out of scope for MVP

- Produce the product boundary and core model summary that will feed:
  - initial project docs
  - repo bootstrap
  - architecture sprint
  - DB/API design sprint

## Constraints

- Keep the model as simple as possible
- Prefer one primary concept: event
- Keep lifecycle minimal
- Keep payload mobile-first and field-friendly
- Avoid rail-specific terms leaking into the platform core
- Do not design full architecture yet
- Do not jump into detailed schema or endpoint design yet
- Do not over-generalize for future verticals beyond what is needed now

## Out of Scope

- Full DB schema
- Full API design
- Full auth implementation
- Complex routing logic
- Detailed notification infrastructure
- UI design
- Complex analytics
- AI / prediction features
- Message bus / NATS design

## Success Criteria

- Domain language is documented and unambiguous
- Core vs vertical-specific concepts are clearly separated
- Event lifecycle is agreed
- Minimum event payload is defined
- Role and permission model is defined at a high level
- MVP boundaries and non-goals are explicit
- Outputs are concrete enough to guide Sprint 3 project/bootstrap work

## Deliverables

- Core domain language summary
- Platform core vs rail-specific boundary summary
- MVP event lifecycle definition
- Minimum event payload definition
- High-level role and permissions summary
- MVP boundary / non-goals summary
- Recommended artifacts to create in Sprint 3

## Notes

This sprint is still definition-first, not implementation-first.

It should create enough clarity that the next sprint can begin creating the actual project structure, initial docs, and first technical artifacts without inventing domain concepts on the fly.