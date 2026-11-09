---
paths:
  - "**/*.cs"
  - "**/*.csproj"
  - "**/*.sln"
  - "**/*.slnx"
---

# .NET service architecture

Working summary of the Confluence pages "Class/Component Taxonomy" (FSE space, page 475562185, v33) and its subpages "Errors and Results" (page 2011037718, v1) and "Events and Messaging" (page 2011627529, v1). The pages are the source of truth: when this file and a page disagree, follow the page and point out the drift.

## Start small

Use the fewest components that do the job. Add a component type only when the use case needs what it is for:

1. Plain CRUD with no rule: the Invoker calls the Data Accessor directly.
2. Any check or rule, including authorization that depends on the resource: add a Handler.
3. Real decision logic: an Engine decides; a Processor applies the decision to loaded Resources.
4. Complex or shared reads: a Provider returns a Data Context.
5. An implementation chosen at runtime: a Registry.
6. A part of a use case that reads, decides, and writes, and is large or shared: a Stage.
7. One use case causing another: a message.

## Components

All injected components are stateless and thread-safe. Every component may call Mappers and Helpers.

| Component | Name | Role | May call |
| --- | --- | --- | --- |
| Resource | `Order` (no suffix) | Domain model owned by this service | — |
| Representation | `CreateOrderRequest`, `OrderResponse`, `OrderEntity` | View of one Resource for one layer | — |
| Data Context | `[Process]Context` | Immutable input bundle for one process; derived lookups yes, decisions no | — |
| Plan | `[Process]Plan` | Instructions an Engine decided | — |
| Controller / Consumer / Listener / Job | `[Resource]Controller`, `[MessageName]Consumer`, `[EventName]Listener`, `{JobType}JobHandler` (see Naming) | Invokers: protocol translation; map requests/responses to Resources | Handler; Data Accessor for plain CRUD only |
| Handler | `[UseCase]Handler` | One whole use case; owns its outcome (validation, not found, result) | Stage, Provider, Registry, Client, Processor, Engine, Data Accessor |
| Stage | `[Name]Stage` | Self-committing part of a use case; returns a result describing what it did | Stage, Provider, Registry, Client, Processor, Engine, Data Accessor |
| Provider | `[Context]Provider` or `[Data]Provider` | Gathers data, reads only; its contract says null vs throw when data is missing | Provider, Data Accessor (reads), Registry, Client, Processor, Engine |
| Engine | `[Purpose]Engine` | Pure, deterministic; returns new values | Engine |
| Processor | `[Purpose]Processor` | Applies changes to loaded Resources in memory; may take an I/O delegate from its caller | Engine |
| Registry | `[Abstraction]Registry` | Takes the deciding value, returns an implementation | — |
| Data Accessor | `[Resource]DataAccessor` | Data operations on Resources this service owns; maps persistence Representations internally | — |
| Client | `[System]Client` | Anything this service doesn't own (vendors, other Foxen services, their client libraries); maps external Representations internally | — |
| Mapper / Helper | `[Resource]Mapper`, `[Subject]Helper`, or `[Type]Extensions` | Static. Mapper: Resource ↔ Representation. Helper: generic utility with no business meaning | Mappers, Helpers |

Existing `*Repository` classes are Data Accessors under their historical name.

## Boundaries

- Handlers are the top of the call graph. When one use case should cause another, the first Handler sends a message and the second use case's Invoker runs its own Handler.
- Writes happen in Handlers and Stages (and in Invokers for plain CRUD). Providers read.
- Engines leave their inputs untouched and do no I/O. Processors mutate in memory and do no I/O.
- Engine decides, Processor applies. When the change is one operation on one Resource, put it in a method on the Resource.
- Ownership picks Client vs Data Accessor, not protocol: an HTTP GET to another service is a Client call.
- Stage → Stage and Provider → Provider calls form trees.
- Business rules live in Engines, or in the Handler while they are small. Invokers, Data Accessors, Clients, Mappers, and Helpers carry none.

## Transactions

One Data Accessor call is one transaction; no transaction spans two calls. Every write leaves valid state on its own: a Handler or Stage can stop after any write, and earlier writes stand. When two writes must succeed together, either the Resource boundary is wrong (make it one Resource saved in one call) or the second write is a consequence of the first and belongs in a durable message.

## Errors

Use cases return expected outcomes as results; faults are thrown.

- A Handler returns a result: either the value, or an error describing an expected way the request ends (not found, invalid input, conflict, stale version, a rule refusing the change). The error says what kind of failure it is and carries what the caller needs to act on it.
- A Stage may return an error in its result the same way; the Handler passes it on or decides what it means.
- Providers return data, usually a Data Context, never a result. Each Provider's contract says how it handles missing data: throw when it can't build what the caller asked for, or return null or an empty context when that just means there is nothing to do.
- Invokers turn the result into the protocol response. Each service maps error kinds to statuses in one place, at the Invoker edge; Core knows nothing about HTTP.
- Throw for faults the caller can't act on: bugs, misconfiguration, infrastructure failures. Where a Data Accessor throws on an expected condition, such as an optimistic-concurrency conflict, the Handler or Stage catches it and returns the matching error.
- Use the result and error types the repo already has. If it has none, ask before adding them.
- Code that still throws domain exceptions for expected outcomes keeps its pattern unless the task is the migration. Ask before choosing for new use cases in such a repo.

## Messaging

- **Durable (outbox):** the message is attached to the Resource and saved by the Data Accessor in the same transaction, then relayed. Delivery is at least once, so Consumers are idempotent. Use it whenever anything depends on the message.
- **Fire-and-forget:** a Handler or Stage publishes after the write; the message can be lost. Use it only for optional signals.
- Handlers, Stages, and Processors may attach durable messages. Prefer a Resource method that records the event as part of the state change (`order.Place()` records `OrderPlaced`), with pending messages exposed read-only.
- The implementation is not settled. Before writing messaging code, check what the repo already has, and ask when it isn't clear.

## Naming

- Name each class for its component role using the suffixes above. "Service" names an architectural boundary, so classes get a role suffix instead.
- Framework-required names are exempt (`BackgroundService`, `DelegatingHandler`, `IExceptionHandler`). This includes `Foxen.Libraries.Jobs`: its `AddJobsFromAssemblies()` registers a job only when the class is named `{JobType}JobHandler`, so Job Invokers keep that suffix.
- In code that predates the taxonomy (`*Service`, `*Manager`, `*Resolver`), keep the existing names unless the task is the rename, and mention the mismatch.
