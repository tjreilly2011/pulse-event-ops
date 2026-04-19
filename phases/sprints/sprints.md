# phases_and_sprints.md

## Recommended Directory Structure

```text
phases/
  PHASE 0 — Discovery & Product Definition/
    sprint_1.md
    sprint_2.md

  PHASE 1 — Foundation & Architecture/
    sprint_3.md
    sprint_4.md

  PHASE 2 — MVP Vertical Slice/
    sprint_5.md
    sprint_6.md
    sprint_7.md

  PHASE 3 — Operational Workflow MVP/
    sprint_8.md
    sprint_9.md
    sprint_10.md

  PHASE 4 — Pilot Readiness/
    sprint_11.md
    sprint_12.md

  PHASE 5 — Generalisation & Expansion Readiness/
    sprint_13.md
    sprint_14.md
```

## Sprint Template

```md
# Sprint X — <Title>

## Phase
<Phase name>

## Goal
<One sentence goal>

## Why This Sprint Matters
<Short paragraph>

## Wishlist
- bullet
- bullet
- bullet

## Constraints
- bullet
- bullet

## Out of Scope
- bullet
- bullet

## Success Criteria
- bullet
- bullet

## Notes
- optional notes
```

---

## `phases/PHASE 0 — Discovery & Product Definition/sprint_1.md`

```md
# Sprint 1 — Problem Discovery & Rail Workflow Validation

## Phase
PHASE 0 — Discovery & Product Definition

## Goal
Validate the core operational problem, the target users, and the first MVP workflow for rail.

## Why This Sprint Matters
This project only works if it solves a real frontline communication problem that staff will actually use under pressure. Before building anything, we need a clear understanding of the most painful workflow failures and the smallest valuable first use case.

## Wishlist
- Define the core frontline user roles for rail MVP
- Define the core operations/control user roles for rail MVP
- Identify the top 3 operational communication failures
- Define the single best first workflow to solve
- Capture current tools/processes being used today
- Document rail-specific constraints that affect MVP design
- Produce a concise problem statement and initial MVP hypothesis

## Constraints
- Do not design software yet beyond what is needed to clarify the workflow
- Do not expand into multiple industries yet
- Keep output focused on one killer use case

## Out of Scope
- Detailed API design
- Detailed database design
- Notifications architecture
- Expansion into airports/logistics

## Success Criteria
- A documented MVP use case exists
- User roles are clearly identified
- The current broken workflow is clearly described
- The first operational value hypothesis is explicit

## Notes
Starting vertical is rail, but wording should not unnecessarily hard-code rail into the platform core.
```

---

## `phases/PHASE 0 — Discovery & Product Definition/sprint_2.md`

```md
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
```

---

## `phases/PHASE 1 — Foundation & Architecture/sprint_3.md`

```md
# Sprint 3 — Repo Foundation, Constitution Alignment & Reuse Audit

## Phase
PHASE 1 — Foundation & Architecture

## Goal
Set up the project foundation, confirm architecture decisions, and audit reusable components/patterns from existing projects.

## Why This Sprint Matters
Before coding core features, we need a clean repo structure, architecture alignment, and a clear view of what can be safely reused without dragging in irrelevant assumptions.

## Wishlist
- Create or confirm final repo structure for:
  - Rust backend
  - HTMX dashboard
  - Flutter mobile app
  - docs
  - phases / sprints
  - prompts
- Update constitution with locked MVP infra choices:
  - Postgres + TimescaleDB
  - SSE first
  - no internal messaging at MVP
  - NATS + JetStream later if needed
- Audit existing projects for reusable patterns:
  - docker
  - postgres
  - dashboard scaffolding
  - auth/session ideas
  - notification clients
  - environment/config handling
- Document reuse candidates and exclusions
- Confirm Rust framework and backend structure direction
- Confirm dashboard placement and mobile project placement

## Constraints
- Reuse only what is understandable and cleanly extractable
- Do not pull trading-specific abstractions into this project
- Keep architecture modular and composable

## Out of Scope
- Implementing event intake
- Implementing dashboard features
- Implementing mobile screens

## Success Criteria
- Constitution is updated
- Repo structure is agreed
- Reuse audit is documented
- Architecture direction is explicit

## Notes
This is the equivalent of a clean runway before feature work begins.
```

---

## `phases/PHASE 1 — Foundation & Architecture/sprint_4.md`

```md
# Sprint 4 — Core Domain Model, Data Model & API Surface Design

## Phase
PHASE 1 — Foundation & Architecture

## Goal
Design the initial domain entities, database schema direction, and MVP API surface.

## Why This Sprint Matters
The MVP depends on a clean event model and a small, explicit API. This sprint should define the shapes before implementation starts.

## Wishlist
- Define initial Postgres / TimescaleDB schema for MVP
- Define core entities:
  - users
  - roles
  - events
  - event_updates
  - locations
  - assignments / queues
  - audit_log
- Define initial API endpoints for:
  - create event
  - list events
  - get event detail
  - update event status
  - add event update
  - stream events via SSE
- Define validation responsibilities
- Define normalization rules
- Define initial audit requirements
- Define realtime delivery pattern at high level

## Constraints
- Postgres is source of truth
- Keep schema simple
- Avoid premature abstraction for multi-tenancy or advanced routing
- Design with extension in mind, not completionism

## Out of Scope
- Full auth implementation
- Push notification implementation
- Mobile offline sync

## Success Criteria
- Core entities are defined
- Initial schema direction is agreed
- API surface is documented
- SSE approach is defined at a high level
```

---

## `phases/PHASE 2 — MVP Vertical Slice/sprint_5.md`

```md
# Sprint 5 — Backend Skeleton, Health, Config & Persistence Foundation

## Phase
PHASE 2 — MVP Vertical Slice

## Goal
Create the Rust backend skeleton with config, health checks, DB connectivity, migrations, and foundational persistence.

## Why This Sprint Matters
This is the first implementation sprint for the backend. It should create a stable base without yet building the full workflow.

## Wishlist
- Create Rust backend application skeleton
- Add configuration loading
- Add environment variable handling
- Add health endpoint
- Add Postgres / TimescaleDB connectivity
- Add migration strategy
- Create initial DB migrations for core tables
- Add basic telemetry / logging scaffolding
- Add basic test scaffolding for backend

## Constraints
- Keep app startup simple
- Keep DB access patterns explicit
- Avoid overbuilding service layers

## Out of Scope
- Event intake logic
- SSE streaming
- Dashboard pages
- Mobile screens

## Success Criteria
- Backend starts cleanly
- Health endpoint works
- DB connects successfully
- Migrations run cleanly
- Foundational tests pass
```

---

## `phases/PHASE 2 — MVP Vertical Slice/sprint_6.md`

```md
# Sprint 6 — Event Intake API & Validation

## Phase
PHASE 2 — MVP Vertical Slice

## Goal
Implement the first operationally meaningful vertical slice: structured event intake with validation and persistence.

## Why This Sprint Matters
This is the first moment where the system becomes useful. It creates the ability to capture real operational events in a structured and auditable way.

## Wishlist
- Implement create-event endpoint
- Implement input validation
- Implement payload normalization
- Persist raw + normalized event data where appropriate
- Create event audit entry on creation
- Implement basic list-events endpoint
- Implement get-event-detail endpoint
- Add unit and integration tests for intake path
- Add deterministic error responses for invalid input

## Constraints
- Keep the event model minimal
- Avoid notifications in this sprint
- Keep event creation deterministic and auditable

## Out of Scope
- Status transitions beyond creation
- Realtime delivery
- Mobile UI
- Dashboard UI

## Success Criteria
- Events can be created via API
- Invalid events are rejected cleanly
- Stored data is auditable
- Listing and detail retrieval work
```

---

## `phases/PHASE 2 — MVP Vertical Slice/sprint_7.md`

```md
# Sprint 7 — Dashboard Event Feed & SSE Realtime

## Phase
PHASE 2 — MVP Vertical Slice

## Goal
Provide a usable operations dashboard event feed with SSE-based live updates.

## Why This Sprint Matters
The operations team needs immediate visibility into incoming events. This sprint proves the realtime model without adding unnecessary infrastructure.

## Wishlist
- Build initial HTMX dashboard page for event feed
- Add event list partial rendering
- Add filters for basic event views
- Implement SSE endpoint for live event updates
- Connect dashboard feed to SSE updates
- Show latest event changes without full page refresh
- Add basic empty / loading / error states
- Test dashboard rendering and SSE flow

## Constraints
- SSE first
- No WebSockets unless absolutely necessary
- No internal message bus
- Keep dashboard focused on truth, not reporting vanity

## Out of Scope
- Mobile app
- Complex analytics
- Push notifications

## Success Criteria
- Dashboard renders current events
- New events appear live via SSE
- Basic filters work
- No manual refresh required for the live feed
```

---

## `phases/PHASE 3 — Operational Workflow MVP/sprint_8.md`

```md
# Sprint 8 — Event Status Lifecycle & Update Workflow

## Phase
PHASE 3 — Operational Workflow MVP

## Goal
Implement the MVP workflow lifecycle for events and allow controlled event updates.

## Why This Sprint Matters
Without workflow, this is just a feed. This sprint turns the product into an operational system by introducing explicit state transitions and event updates.

## Wishlist
- Implement event status transition rules
- Add endpoint to change status
- Add endpoint to add event updates/comments
- Persist event update history
- Persist status transition audit entries
- Show event history in dashboard detail view
- Show current status clearly in dashboard
- Test valid and invalid state transitions

## Constraints
- Keep lifecycle simple
- Model transitions explicitly
- Maintain full auditability

## Out of Scope
- Sophisticated routing engine
- Notifications
- Mobile full workflow UI

## Success Criteria
- Event state transitions work
- Event history is visible
- Invalid transitions are blocked
- Audit trail is complete
```

---

## `phases/PHASE 3 — Operational Workflow MVP/sprint_9.md`

```md
# Sprint 9 — Roles, Permissions & Queue Ownership

## Phase
PHASE 3 — Operational Workflow MVP

## Goal
Add MVP authorization, role visibility, and basic queue/ownership concepts.

## Why This Sprint Matters
The system cannot become operationally credible until it controls who can see and change what.

## Wishlist
- Define and implement MVP roles
- Implement authentication placeholder or chosen auth path
- Add authorization checks to event APIs
- Implement basic queue or assignment ownership
- Restrict status change actions by role where needed
- Reflect queue / assignee info in dashboard
- Add tests for permission failures and allowed actions

## Constraints
- Keep role model simple
- Avoid enterprise IAM complexity
- Focus on MVP operational safety

## Out of Scope
- SSO
- Advanced admin tooling
- Complex org hierarchy

## Success Criteria
- Roles exist and are enforced
- Unauthorized actions are blocked
- Queue / ownership model works at MVP level
```

---

## `phases/PHASE 3 — Operational Workflow MVP/sprint_10.md`

```md
# Sprint 10 — Flutter Frontline Reporting App (MVP)

## Phase
PHASE 3 — Operational Workflow MVP

## Goal
Create the first Flutter mobile app flow for frontline staff to submit and review events.

## Why This Sprint Matters
This sprint tests the core assumption that frontline staff will use a simple mobile-first interface under operational pressure.

## Wishlist
- Create Flutter app scaffold if not already present
- Build login/session placeholder or auth integration path
- Build create-event screen
- Build simple recent-events screen
- Submit events to backend API
- Show validation errors clearly
- Show success confirmation clearly
- Keep workflow minimal-tap and mobile-first
- Add basic app-level tests / smoke validation

## Constraints
- Do not build a desktop mindset into mobile
- Keep submission flow extremely simple
- Avoid feature creep

## Out of Scope
- Offline sync sophistication
- Rich media uploads
- Full event lifecycle management in mobile

## Success Criteria
- Frontline user can submit an event from mobile
- Recent events view works
- UX is simple enough for pilot use
```

---

## `phases/PHASE 4 — Pilot Readiness/sprint_11.md`

```md
# Sprint 11 — Notifications, Operational Alerts & Reliability Basics

## Phase
PHASE 4 — Pilot Readiness

## Goal
Add basic notification/alert capability and reliability protections required for pilot usage.

## Why This Sprint Matters
The product becomes much more operationally valuable once relevant users can be notified and the system handles common failure modes more gracefully.

## Wishlist
- Define MVP notification triggers
- Implement basic notification service abstraction
- Add at least one practical delivery channel for pilot use
- Persist notification attempts and outcomes
- Add duplicate-submission protection where needed
- Improve retry/error handling for key flows
- Improve logging around event creation and update flow
- Test notification and failure paths

## Constraints
- Notifications are not source of truth
- Keep implementation simple
- Avoid overbuilding delivery infrastructure

## Out of Scope
- Multi-channel enterprise notification center
- Escalation engine
- Message bus

## Success Criteria
- Basic alerts can be sent
- Notification attempts are auditable
- Reliability is improved for pilot scenarios
```

---

## `phases/PHASE 4 — Pilot Readiness/sprint_12.md`

```md
# Sprint 12 — Hardening, Deployment, Observability & Pilot Packaging

## Phase
PHASE 4 — Pilot Readiness

## Goal
Make the system deployable, observable, and ready for a controlled pilot.

## Why This Sprint Matters
Pilot readiness is not just features. It requires visibility into system health, clean deployment flow, and confidence that failures can be understood quickly.

## Wishlist
- Finalize docker/dev runtime setup
- Add deployment documentation
- Add observability basics:
  - health
  - logs
  - operational metrics
- Improve error handling and startup robustness
- Add smoke-test guidance
- Validate end-to-end happy path
- Validate key failure paths
- Produce pilot readiness checklist

## Constraints
- Keep infra simple
- No cloud-specific lock-in yet
- Focus on operational readiness, not scale theater

## Out of Scope
- NATS
- advanced analytics
- AI features

## Success Criteria
- System can be started reliably
- Health and logs are useful
- Pilot checklist is complete
- MVP can be demoed and trialed end-to-end
```

---

## `phases/PHASE 5 — Generalisation & Expansion Readiness/sprint_13.md`

```md
# Sprint 13 — Generalise Core Event Platform Beyond Rail

## Phase
PHASE 5 — Generalisation & Expansion Readiness

## Goal
Refactor and document the platform core so that it remains rail-capable but is no longer rail-shaped internally.

## Why This Sprint Matters
If expansion is a real goal, the core event platform needs to support future operational verticals without a rewrite.

## Wishlist
- Audit rail-specific naming in core models and APIs
- Move rail-specific concepts to edges where possible
- Confirm generic event core remains intact
- Define extension points for vertical-specific event types
- Document what belongs in platform core vs vertical modules
- Identify remaining rail coupling risks

## Constraints
- Do not rewrite working MVP unnecessarily
- Refactor only where future reuse is materially improved

## Out of Scope
- Building second vertical features
- NATS adoption
- advanced routing engine

## Success Criteria
- Core domain is more generic
- Rail-specific behavior is better isolated
- Future extension path is documented
```

---

## `phases/PHASE 5 — Generalisation & Expansion Readiness/sprint_14.md`

```md
# Sprint 14 — Scale Readiness: WebSockets/NATS Decision Gate

## Phase
PHASE 5 — Generalisation & Expansion Readiness

## Goal
Assess whether the product now needs WebSockets and/or NATS + JetStream, and prepare the smallest clean upgrade path if justified.

## Why This Sprint Matters
This sprint is not about adding complexity for its own sake. It exists to make the scale transition deliberate and evidence-based.

## Wishlist
- Evaluate current SSE limitations in real usage
- Evaluate whether internal async workloads justify a bus
- Define criteria for adopting WebSockets
- Define criteria for adopting NATS + JetStream
- Design post-commit event publishing pattern
- Keep Postgres as source of truth
- Produce a scale decision memo

## Constraints
- No premature infra upgrades
- No replacement of Postgres
- NATS only if justified by actual needs

## Out of Scope
- Kafka
- large-scale infra redesign
- speculative cloud complexity

## Success Criteria
- Clear scale decision criteria exist
- NATS/WebSocket adoption path is documented
- No unnecessary complexity is introduced early
```


###### sprints again:

🚀 FULL ROADMAP (now fixed, build-focused)

Phase 1 — MVP (you are here)

Goal: working system used by ONE user flow

⸻

✅ Sprint 3 — Minimal Event API (you already have)

→ create + read events

⸻

Sprint 4 — Event Updates & Acknowledgment

Adds:

* PATCH /events/{id}/acknowledge
* POST /events/{id}/updates
* event status updates
* event timeline table

Now you have:

* create event
* someone acknowledges (ownership)
* updates recorded

👉 This is your core workflow alive

⸻

Sprint 5 — Realtime (SSE)

Adds:

* /events/stream (SSE endpoint)
* push updates to connected clients

Now you have:

* live updates (no refresh)
* replaces phone “what’s happening?” calls

⸻

Sprint 6 — Basic Web Dashboard (HTMX)

Adds:

* event list page
* event detail page
* live updates via SSE
* acknowledge button

Now you have:

* usable ops dashboard

⸻

Sprint 7 — Simple Mobile UI (Flutter stub)

Adds:

* create event screen
* quick actions (hardcoded for now)
* submit event

Now you have:

* full loop:
    * mobile → backend → dashboard

⸻

🧪 Phase 2 — Pilot

Goal: usable by real people (your brother)

⸻

Sprint 8 — Role Awareness (lightweight)

Adds:

* basic roles:
    * frontline
    * management
* filter events by role/location

⸻

Sprint 9 — Notifications (basic)

Adds:

* push notifications (or simple polling fallback)
* notify on:
    * event created
    * acknowledged

⸻

Sprint 10 — Location Model

Adds:

* locations table
* attach events to locations
* basic “next station” logic (simple version)

⸻

Sprint 11 — Deploy + Test Pilot

Adds:

* deploy backend (cheap VPS / Fly.io / Railway)
* test with 1–2 real users
* collect feedback

⸻

🏗 Phase 3 — Productisation

⸻

Sprint 12 — Permissions (real)

* who can see/update what

⸻

Sprint 13 — Audit & History

* full event timeline
* who did what, when

⸻

Sprint 14 — Better Workflow States

* refine lifecycle
* edge cases

⸻

🧠 Phase 4 — Intelligence (later)

Ignore for now.

⸻

🌍 Phase 5 — Expansion

Only AFTER pilot success.

⸻

🔥 What matters right now

Forget everything beyond:

👉 Sprint 3 → Sprint 5

That gets you:

* working backend
* real-time updates
* usable core system

⸻

🧠 Critical correction to your process

You don’t need:

❌ 10 markdown files per sprint
❌ full domain modelling upfront

You need:

✅ thin definition
✅ immediate build
✅ feedback loop

⸻

🎯 Your execution for TODAY

You said:

“i will start now with sprint 3”

Perfect.