# Starting work

- Before proposing a design, look up the facts yourself: which service owns the Resources involved, which similar use cases already exist in the repo, and which patterns (results, messaging, tests) it already uses.
- Work in this order: well-understood behavior, including edge cases; then decomposition into taxonomy components by complexity and reuse; then the shapes of inputs, outputs, Resources, and interfaces; then the tests.
- The tests are the spec: unit tests for each component (mocks are fine) and integration tests for each use case. An agent given only the tests should be able to compile a specification and rebuild an implementation with the same behavior.
- Build the thinnest end-to-end slice first, then add components only as the use case needs them.
- For a new feature or a ticket that adds use cases, suggest `/kickoff` before writing code, then `/exact` to build what it agreed.
- While getting to green, keep every existing test as written. When one looks wrong, stop and say why.
