---
name: kickoff
description: Start new backend work (a Jira ticket, story, or feature) by interviewing the user from behavior through decomposition, shapes, and tests, before any implementation is written.
disable-model-invocation: true
---

Kick off a piece of backend work. The goal is well-understood behavior, including its edge cases, captured as tests that serve as the spec. The tests ARE the spec: a reader could compile a complete specification from them and port the working behavior to a different implementation, language, or framework. Write no implementation code during a kickoff.

## 1. Gather the facts

Facts are your job; decisions are the user's. Before asking anything:

- If the user gave a Jira key or Confluence link, read it, including linked parent stories and sub-tasks.
- Read `~/.claude/rules/dotnet-architecture.md`. Phases 3 and 4 below are organised by it.
- In the repo, find: which service owns each Resource the work touches, existing use cases that resemble this one, the patterns the repo already uses for results, errors, and messaging, and how its existing tests are written. Dispatch an Explore subagent when this needs more than a few lookups.

Done when you can name the owning service for each Resource and point to at least one comparable use case in the code, or have confirmed there is none.

## 2. Interview

Work through the phases in order; each one builds on the answers before it. Within a phase, ask one question at a time, give your recommended answer, and word it so "yes" accepts it. Explore the codebase instead of asking whenever the answer is a fact.

### Phase 1: Behavior

Reach well-understood behavior before any class is named.

- **Use cases:** what they are, who or what starts each one, and what it achieves.
- **Ownership:** which Resources this service owns, and which belong to other systems.
- **Outcomes:** the value each use case returns, and every expected error (not found, invalid, conflict, stale version, a rule refusing the change).
- **Edge cases:** boundaries, empty and missing data, duplicates and retries, concurrent changes, partial failure, time (period boundaries, time zones, effective dates). Hunt for them; every one gets an agreed outcome.
- **Consequences:** what must happen because of each write, and what other use cases or services react.

Record each use case as an example map: its rules, each rule's concrete examples (the given, the action, and the exact outcome), and its open questions.

Done when every use case has its outcomes and edge cases agreed, each stated as observable behavior, and every rule has at least one concrete example.

### Phase 2: Decomposition

Break the behavior into components of the taxonomy, sized by complexity and reuse.

- One Handler per use case, behind its Invoker (Controller, Consumer, Listener, Job).
- Add Engines, Processors, Providers, Registries, and Stages only where a use case's complexity or sharing across use cases justifies them. Recommend the fewest components, and say what earns each one.
- Writes and transactions: every write leaves valid state on its own; consequences that must happen travel as durable messages.

Done when every behavior from Phase 1 has a component responsible for it, and every component has a stated reason to exist.

### Phase 3: Shapes

- **Inputs and outputs** of each use case: commands, queries, results, and errors.
- **Resources:** fields, invariants, and the methods that change them (including the events those methods record).
- **Interfaces** of each component from Phase 2, and the Representations at each edge.

Done when every component's interface and every use case's input and output are written down.

### Phase 4: Tests

The test suite is the spec. Plan it so that an agent given only the tests could compile a specification and rebuild an implementation with the same behavior.

- **Unit tests** for each component from Phase 2, with its dependencies mocked: its responsibilities, its edge cases, and how it uses its collaborators.
- **Integration tests** for each use case, through the Handler (or the Invoker for protocol behavior) with real or in-memory storage: the returned value or error, the Resources' resulting state, and the messages emitted.
- Name each test as a sentence of the spec, given / when / then.
- Order and split the list by "Build it" in `~/.claude/skills/exact/test-list.md`: driving tests by slice, then verification tests.

Done when every behavior and edge case from Phase 1 maps to at least one named test, every component from Phase 2 has unit tests covering its interface from Phase 3, and every test is marked driving or verification.

## 3. Summarise and confirm

Present the kickoff summary:

- **Behavior:** each use case's example map: rules, examples with exact outcomes, and edge cases.
- **Components:** a table of Invoker → Handler → components, with what earns each component.
- **Shapes:** inputs, outputs, Resources, and interfaces.
- **Tests:** the ordered test list: driving tests by slice, then verification tests with the driving tests each relies on.
- **Build order:** the thinnest end-to-end slice through one use case first (its tests go red, then green), then the slices that grow it, each one independently mergeable.
- **Open questions:** anything parked, with who can answer it.

Ask the user to confirm the summary. Offer to post it to the Jira ticket. Start implementing only when the user says so, and suggest `/exact` to build it.
