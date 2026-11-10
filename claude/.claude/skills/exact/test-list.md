# Test list

The test list is the spec in executable form: every agreed example becomes a test, in the order it will be driven. `/kickoff` plans it; `/exact` writes it into the code, skipped.

## Build it

1. **Examples.** Walk each use case's rules and examples. Each example becomes at least one test whose name is a spec sentence stating the given, the action, and the exact expected outcome: the value, the error kind, or the status.
2. **Rejections.** Every rejection states its observable contract: the error kind the Handler returns and its status at the Invoker edge. Where the agreed behavior leaves it open, choose the most defensible reading, put it in the name, and list it at the checkpoint.
3. **Level.** A use case's outcome is an integration test through its Invoker. A component's own edge cases that are cheaper to pin directly are unit tests on that component.
4. **Order.** Driving tests go by slice: the thinnest end-to-end path of the first use case first, then the tests that grow it. Within a slice, simple before complex: empty or single case, each rule alone, rules with modifiers, combinations, multi-step. A component's unit tests sit directly after the integration test that first brings the component in.
5. **Cross-check.** For each independently specified dimension (operation, entity or variant, input category, policy attribute, state transition, result), take the counterfactual: if one specified entry or rule changed while its neighbours stayed correct, would some test fail? Add a test for every cell where none would. Parallel catalogues, mappings, and switch arms need one test per entry when entries can drift independently, and one representative test when a single uniform rule governs them.
6. **Split.** For each test, ask: once the tests before it are built minimally, will it fail? If so, it drives. If it should pass because its parts already exist, such as a combination of built rules, another value of a generalized rule, or a unit test of behavior its integration test already forced, it is a verification test. Move it after all the driving tests and name the driving tests it relies on. A combination that needs its own rule (a precedence, an interaction, a special case) drives, placed right after the tests for its parts.

Done when every agreed example has a test, every rejection has an observable contract, the cross-check finds no uncovered cell, and every verification test names the driving tests it relies on.

## Write it

Write each test skipped, with its name and an empty body, using `dotnet.md`. Follow list order, with the verification tests last. The Red phase writes each body.

Then summarize:

```
Test List Created:
**Feature**: <name>
**Test files**: <paths>

**Driving tests** (in order):
1. <test name>
...

**Verification tests**:
- <test name> -- relies on <driving tests>

**Coverage cross-check**: <dimensions reviewed; catalogues checked; where a representative test suffices and why>
**Readings adopted**: <open contracts and the reading chosen>
```
