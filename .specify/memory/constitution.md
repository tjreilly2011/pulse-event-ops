# constitution.md

## Project
pulse-event-ops

## Purpose
Build a focused, reliable, real-time operational intelligence platform that enables frontline staff and operations teams to capture, communicate, coordinate, and act on live events in structured workflows.

The product starts with rail operations and is designed to expand later into other operational environments such as airports, logistics, venues, field services, and emergency coordination.

## Core Mission
Ship a simple, trustworthy operational platform that can:
1. capture an event quickly from the frontline,
2. normalize and validate it,
3. route it to the right people and surfaces,
4. maintain an auditable lifecycle,
5. display operational truth clearly in real time.

## Architecture
Frontline Staff (Flutter Mobile App)
    ↓
API Gateway / Rust HTTP Layer
    ↓
Event Intake / Validation Layer
    ↓
Event Classification / Routing Engine
    ↓
Workflow / State Transition Engine
    ↓
Notification / Realtime Broadcast Layer
    ↓
Postgres / TimescaleDB
    ↓
HTMX + DaisyUI Operations Dashboard
    ↓
Push / Email / SMS / Other Notifications

Optional later:
Analytics / Intelligence Layer
    ↓
WASM modules for isolated performance-critical client-side workloads

## Primary Goal
Reach a usable MVP quickly for real-world frontline operational event reporting and live dashboard visibility, starting with rail and using a modular architecture that supports later expansion into adjacent industries.

## Non-Goals (for now)
- No AI or LLM in the operationally critical decision path
- No premature multi-tenant enterprise platform complexity
- No complex microservice sprawl at MVP stage
- No attempt to solve every operational use case in v1
- No safety-critical automation or dispatch authority logic
- No broad integration surface before the core workflow is proven
- No overbuilt analytics layer before the event lifecycle is reliable
- No speculative “smart” features unless they measurably improve workflow outcomes

## Design Principles
- Prefer boring, testable systems over clever ones
- Keep the critical operational path deterministic
- Every event and state transition must be explainable after the fact
- Every meaningful action must produce a persisted audit trail
- Optimize for speed to validated pilot, not architectural vanity
- Build composable modules so vertical-specific workflows can evolve independently
- Default to generic event models with domain-specific extensions
- Design for mobile-first frontline use, not desktop-first adaptation
- Favor explicit workflows over hidden system behavior
- Build for degraded environments: weak signal, intermittent connectivity, user stress

## Engineering Principles
- Follow SOLID principles throughout the codebase
- Favor composition over inheritance
- Keep domain logic separate from transport, UI, and persistence concerns
- Use clear interfaces and contracts between modules
- Avoid tight coupling between rail-specific concepts and the generic event platform core
- Keep modules small, understandable, and replaceable
- Design for extension without forcing premature abstraction
- Prefer stable, typed domain models over dynamic ad hoc payloads

## System Priorities
1. Correctness
2. Reliability
3. Auditability
4. Observability
5. Simplicity
6. Speed of iteration
7. Extensibility

## Agreed Architecture
### Frontend
- Frontline mobile app: Flutter
- Operations dashboard / admin tools: Jinja2 + HTMX + DaisyUI

### Backend
- Core backend services: Rust
- API layer: Rust
- Persistence: PostgreSQL with TimescaleDB extension
- Realtime delivery to clients: SSE first
- WebSockets may be added later where clearly justified

### Internal Messaging
- None at MVP
- No message bus in the initial operational path

### Optional Later
- NATS + JetStream is the preferred first internal event bus if decoupled async processing becomes necessary
- WASM only for isolated performance-critical modules
- AI / intelligence only outside the critical operational path

## Final Tech Choice (Locked for MVP)
### Database
- PostgreSQL with TimescaleDB extension

### Realtime to Clients
- SSE first
- WebSockets may be added later where clearly justified

### Internal Messaging
- None at MVP
- No message bus in the initial operational path

### Next-Step Bus (Only If Needed)
- NATS + JetStream is the preferred first internal event bus if decoupled async processing becomes necessary

## Product Rule
A smaller working operational product used by real people is more valuable than a large unfinished platform.

## Domain Rule
The system must treat operational events as first-class objects with clear lifecycle, ownership, routing, and audit history.

The platform core must remain generic even when the first implementation is rail-focused.

## Initial Scope
Rail-focused MVP with:
- structured event reporting from frontline staff
- live event feed for operations/control users
- event categorization and basic routing
- role-based visibility
- event status lifecycle
- realtime updates
- push notifications
- audit trail
- operational dashboard

## Expansion Rule
Rail is the first vertical, not the final product boundary.

The core platform should be designed so that future verticals can reuse:
- event intake
- workflow engine
- notification patterns
- dashboard patterns
- role/permission models
- audit logging
- realtime event delivery

Future vertical packs may include:
- airports
- venues/stadiums
- logistics / depots / warehouses
- field services
- utilities
- incident coordination teams

## Do
- Keep the core event model generic and extensible
- Separate domain logic from UI and framework code
- Store raw input, normalized event, routing decisions, status changes, and notifications
- Use feature flags or config toggles for non-core features
- Build dashboard views for truth, not vanity
- Design workflows so users can complete key actions in minimal taps/clicks
- Reuse proven patterns and scaffolding where safe and clean
- Favor explicit interfaces between ingestion, workflow, storage, and notifications
- Treat mobile UX under pressure as a core product requirement
- Build with offline-aware patterns where practical

## Don’t
- Don’t place LLMs or agents in the operationally critical path
- Don’t hardwire rail-specific assumptions deep into the core model
- Don’t let one service own too many unrelated concerns
- Don’t hide workflow decisions behind opaque heuristics
- Don’t optimize for many verticals before one vertical is validated
- Don’t add integrations unless they are clearly useful, logged, and testable
- Don’t overbuild analytics before the event lifecycle is stable
- Don’t create microservices just to look enterprise-ready
- Don’t confuse more features with better workflow
- Don’t allow convenience to undermine auditability
- Don’t replace Postgres early in pursuit of “realtime database” features
- Don’t introduce Kafka, Redpanda, RabbitMQ, NATS, or similar infrastructure during MVP unless there is a proven operational need

## Runtime Rule
The path from event intake to stored operational state must be deterministic and reproducible from stored inputs.

## Auditability Rule
For every event, persist:
- raw payload
- normalized payload
- event type
- source channel
- source user / device when available
- location context
- validation result
- routing decision
- workflow state transitions
- user actions
- notification attempts
- notification results
- timestamps for all meaningful changes

## Reuse Rule
Before building new modules, inspect existing internal/project patterns for:
- dashboard scaffolding
- auth/session patterns
- Docker setup
- Postgres usage
- notification clients
- deployment conventions
- shared UI utilities
- testing patterns

Only reuse code that is:
- understandable
- testable
- small enough to extract cleanly
- compatible with the new architecture
- not coupled to trading-specific assumptions

## Architecture Rule
The system must be decomposed into clear composable parts:
- intake
- normalization
- validation
- routing
- workflow/state management
- notifications
- realtime delivery
- storage
- dashboard/UI
- mobile client
- analytics/intelligence

Each part should be independently understandable and testable.

## Realtime Rule
For MVP:
- PostgreSQL / TimescaleDB is the source of truth
- Rust backend owns validation, workflow, and realtime fan-out
- SSE is the default mechanism for dashboard realtime delivery
- WebSockets are optional later, not default now

## Messaging Rule
Do not introduce Kafka, Redpanda, NATS, RabbitMQ, or similar infrastructure during MVP unless there is a proven operational need.

If internal messaging becomes necessary after MVP:
- prefer NATS + JetStream first
- keep database as system of record
- publish events only after successful DB commit

## Database Rule
PostgreSQL + TimescaleDB is the default persistence layer for:
- operational events
- audit logs
- workflow state
- analytics-ready event history

Do not replace Postgres early in pursuit of “realtime database” features.

## Source of Truth Rule
Notifications, SSE streams, WebSockets, and any future message bus are delivery mechanisms.
Postgres remains the source of truth.

## SOLID / Composition Rule
All core modules must follow these expectations:
- Single Responsibility: each module should do one thing well
- Open/Closed: extension should be preferred over invasive modification
- Liskov Substitution: implementations must honor interface contracts
- Interface Segregation: consumers should depend only on the methods they need
- Dependency Inversion: high-level policies depend on abstractions, not concrete frameworks

Prefer:
- composition
- adapters
- interfaces/traits
- policy modules
- configuration-driven behavior

Avoid:
- god objects
- giant service classes
- framework-leaking domain logic
- brittle cross-module assumptions

## Product Philosophy
Operational software should reduce friction, reduce chaos, and increase shared situational awareness.

The product wins if it is:
- fast to use
- easy to trust
- clear under pressure
- simple to operate
- auditable later

## User Experience Rule
If a frontline user cannot perform the core action quickly under stress, the design is wrong.

## Mobile Rule
The frontline mobile experience is not a trimmed-down desktop app.
It is its own primary surface with its own workflow constraints.

## Dashboard Rule
The dashboard exists to show operational truth clearly and support action.
It must not become a reporting vanity layer.

## Workflow Rule
Every operational event must have:
- a clear current status
- a visible history
- a responsible role or queue
- explicit state changes
- timestamps
- user traceability where possible

## Security Rule
The system must:
- authenticate users securely
- authorize access by role and scope
- protect sensitive operational data
- avoid overexposure of data between teams/regions
- maintain audit logs for critical actions

## Reliability Rule
Operational truth must survive:
- flaky connections
- partial retries
- duplicate submissions
- stale clients
- notification failures

The system must be resilient to common operational failure modes.

## Observability Rule
The system must expose enough logs, metrics, and traces to answer:
- what happened
- when it happened
- who triggered it
- what the system decided
- whether users were notified
- what failed

## Success Criteria
The system succeeds when it provides:
- stable event ingestion
- reproducible event normalization and routing
- reliable realtime visibility
- auditable workflows
- usable frontline mobile reporting
- a dashboard that reflects real operational state
- the ability to add a second vertical without core rewrites

## MVP Success Criteria
For the first rail pilot, success means:
- staff can submit structured events quickly
- ops users can see live events without refresh
- event lifecycle can be updated and audited
- notifications reach intended users reliably
- the system is usable in real operational conditions
- the product produces clear feedback for iteration

## Testing Policy

All core platform modules must include:

- unit tests
- integration tests
- workflow/state transition tests
- permission/authorization tests
- validation tests
- notification tests where applicable

Frontend surfaces should include:
- key happy-path tests
- key failure-path tests
- basic rendering/smoke coverage

No operationally meaningful workflow may ship without passing tests.

## Operational Safety Rules

Before any meaningful pilot or production use:

- dry-run / non-disruptive verification mode where appropriate
- authentication and authorization checks
- duplicate submission safety checks
- notification delivery validation
- audit trail verification
- rollback / kill-switch capability for risky changes
- minimal-scope deployment first

Production usage must include:
- kill switch
- monitoring dashboard
- manual override for administrative correction
- clear incident logging for system faults

## Data Rule
Persist operational data in a way that supports:
- audit
- replay/reconstruction
- analytics later
- extension into new verticals

Do not optimize the schema only for today’s rail use case if it harms future reuse.

## Notification Rule
Notifications are a delivery mechanism, not the source of truth.
The database-backed event state is the source of truth.

## Intelligence Rule
Any future intelligence layer must:
- be optional
- be measurable
- not obscure operational truth
- never replace the auditable core workflow state
- stay outside the operationally critical path unless explicitly justified and proven safe

## Sprint Artifact Location Policy

Planning and execution artifacts are authored in `ralph/` during active sprint execution.

Active sprint working files:

`ralph/plan.md`

`ralph/tasks.md`

`ralph/PROGRESS.md`

`ralph/` is a temporary working directory and must not be committed.

Committed copies must live under the active feature spec archive:

`specs/<feature-id>/sprints/<sprint-id>/`

Required persisted files include:

- plan.md
- tasks.md
- PROGRESS.md

Sub-agents should continue reading/writing `ralph/` paths during sprint execution.

Before any checkpoint/release commit that needs sprint records, copy current `ralph` files into the matching `specs/<feature-id>/sprints/<sprint-id>/` directory and commit the copied files only.

## PR Gate Policy

Before raising a PR to `main`, all of the following must be confirmed:

### 1. Tests pass
- Run the relevant backend and frontend test suites
- All required tests must be green with no failures

### 2. Linting is clean
- Run Rust linting/formatting and relevant frontend linting/formatting
- Zero blocking violations

### 3. System smoke test
- Start the required app stack
- Confirm backend startup is healthy
- Confirm dashboard renders
- Confirm mobile/API happy path works
- Confirm at least one key failure path is handled cleanly
- Check logs for unexpected errors or tracebacks

### 4. DB schema is consistent
- If schema or migration files were modified, verify the live DB reflects those changes
- Schema drift between migrations and live DB is a blocker

### 5. No committed `ralph/` files
- Confirm `ralph/` is not staged or committed

### 6. README.md is up to date
- Verify README reflects the sprint’s new capabilities
- Add or update sections for:
  - new endpoints
  - new config vars
  - new background tasks
  - changed behavior
  - new mobile/dashboard capabilities

Only once all six gates above pass should the PR be raised and merged to `main`.

## API Design Rule
APIs must be:
- explicit
- versionable
- typed where possible
- safe for replay
- easy to audit

Avoid endpoints that bury business logic behind vague payloads.

## Workflow Design Rule
Status changes and routing decisions must be modeled as explicit transitions, not loose field edits scattered through the codebase.

## Proposed Project Structure
pulse-event-ops/
  README.md
  constitution.md
  docker-compose.yml
  .env.example

  docs/
    01-product-vision.md
    02-domain-model.md
    03-event-intake.md
    04-validation-and-normalization.md
    05-routing-engine.md
    06-workflow-engine.md
    07-notifications.md
    08-realtime-delivery.md
    09-dashboard.md
    10-mobile-app.md
    11-data-model.md
    12-security-and-permissions.md
    13-observability.md
    14-expansion-strategy.md
    15-reuse-plan.md

  apps/
    mobile/
    dashboard/

  services/
    api/
    workflow/
    notifications/

  src/
    config/
    domain/
    application/
    ports/
    adapters/
    workflows/
    notifications/
    storage/
    auth/
    realtime/
    integrations/
    telemetry/
    shared/

  migrations/
  tests/
  scripts/

## Technology Direction
### Mobile App
- Flutter

### Dashboard
- Jinja2
- HTMX
- DaisyUI

### Backend
- Rust

### Database
- PostgreSQL with TimescaleDB extension

### Realtime
- SSE first
- WebSockets only where clearly justified later

### Internal Messaging
- None at MVP
- NATS + JetStream only if justified later

### Optional Performance Modules
- WASM only when clearly justified

## Final Rule
A simple operational system that real users trust is more valuable than a sophisticated platform nobody adopts.
