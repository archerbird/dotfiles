# The predictive cycle

## Core rules

1. Exactly one test is active and unfinished at a time.
2. Before every build or test run in this workflow, write a falsifiable prediction: whether it compiles, the passed, failed, and skipped counts, and for each failure its assertion and values. Run it immediately after.
3. Compare prediction and result explicitly and mark each prediction `Correct` or `Incorrect`. An unexpected result stays `Incorrect`.
4. A valid red fails because the active behavior is missing, for the predicted reason.
5. Green is the smallest production change that passes the active test and keeps every earlier test green.
6. Refactor only on green.
7. Every existing test stays as written. When one looks wrong, stop and say why; changing it is the user's call.
8. Where the agreed behavior leaves an observable contract open, state the reading you adopt in the test name and raise it at the next checkpoint.

Routine file and git operations need no prediction.

## 1. Choose the test

Take the next driving test and ask: with the code as it is now, will it fail?

- Yes: it drives. Continue.
- No, because an earlier test already forced the behavior: move it, still skipped, to the end of the verification tests, naming that earlier test in its skip reason, and take the next driving test. If you cannot name the earlier test, the code may do more than any test demanded; leave the test in place and let the run decide.

Move a test only before activating it. State its given, its action, and its exact expected outcome in the domain's words. Then remove its skip and write its body.

## 2. Red

Open with `## Red -- Test N: <test name>`. Predict the focused run from `dotnet.md`, then run it.

If the build fails or the test errors before its assertion, add only the scaffold the assertion needs to run: the route, the type, a method signature returning a default, the DI registration. Predict and run again, until the failing assertion is the missing behavior.

If a driving test passes, record the runtime prediction as `Incorrect`, find which earlier change made it pass, and make no production change.

Close with both lines, verbatim, every time:

```
Red Phase Complete:
**Compilation Prediction**: <what you expected> Correct|Incorrect
**Runtime Prediction**: <what you expected> Correct|Incorrect
```

## 3. Green

Open with `## Green -- <what was added>`. Make the smallest production change likely to pass the active test, without anticipating skipped tests; a hardcoded value or a narrow condition is a valid step. When the change needs a new component, add the one the "Start small" ladder in `dotnet-architecture.md` gives for what this test needs now.

Predict the focused run and run it.

## 4. Refactor

Open with `## Refactor -- <what improved, or "no improvement possible">`. Emit it every cycle, including cycles that change nothing; a cycle without it is indistinguishable from a skipped review.

Review the code this cycle touched against the Four Rules of Simple Design, in order:

1. Passes the tests.
2. Reveals intent.
3. No duplicated knowledge.
4. Fewest elements.

Rule 2 has two lenses that answer different questions. Apply the domain lens first, then the architecture lens.

### Domain lens: which policy deserves a name

This lens is domain capability, in the ubiquitous language of the agreed behavior: the kickoff's rules and examples, and the ticket.

- State each touched unit's responsibility as one domain sentence in the spec's terms. "Process", "handle", "evaluate", or "calculate the result" is too broad to show cohesion.
- Name the policies the unit owns, then ask the change counterfactual: if one policy changed while another stayed fixed, would this unit change for both reasons? If so, that is a candidate seam.
- Keep cohesive knowledge together. Split for an independently changing policy, never just to shorten a method.

When a credible seam exists, the trial is mandatory: analysis alone is not the attempt. Make the smallest move that makes the policy visible under a name from the spec: extract the policy calculation, extract the predicate that states when a rule applies, or consolidate duplicated domain knowledge behind its owning concept. Keep the move when the names make the policy easier to find and change; otherwise undo the whole trial.

Record before the trial:

```
Domain responsibility: <one sentence in spec language>
Independent change axes: <policies that can change independently>
Boundary candidate: <the strongest seam and the move to try, or none>
```

Record after:

```
Boundary outcome: <retained | undone>
Semantic change: <what the boundary now makes visible, or why it did not>
```

With `Boundary candidate: none`, name the domain rules that make the unit one decision. "It is small" is not evidence.

### Architecture lens: what hosts it

This lens is technical capability, from `dotnet-architecture.md`. For every unit the domain lens kept or created, the taxonomy decides the component type, its call rules, and its name. Separating orchestration, protocol translation, persistence, and external calls belongs to this lens. A domain seam starts as a well-named method in its host, such as a method on the Resource, the Engine, or the Handler while it is small. It becomes its own component only when the "Start small" ladder says so.

Check the call rules and names of every component the cycle touched.

### Fewest elements

Apply Rule 4 last. A named element that isolates an independently changing policy is necessary and stays, and so is a component the taxonomy requires.

```
Fewest Elements check: <why each retained element is necessary>
```

Make one refactoring at a time, and predict and run the focused tests after each. Undo any refactoring that fails its check.

## 5. Close

Predict and run the close gates from `dotnet.md`. Record compactly: the behavior, the red evidence, the green change, the refactor decision, the gates, and the next skipped test. Start the next cycle unless a checkpoint stops you.

## Growing the list

Behavior you discover mid-cycle, such as an edge case or a missing outcome, goes on the list as a skipped test and stays out of the active cycle. If the agreed behavior does not cover it, raise it at the next checkpoint before driving it. A component edge case that is cheaper to pin at unit level, such as an Engine's boundary math, a Mapper, or a Processor's in-memory change, goes on as a driving unit test directly after the active test.

## Verification part

Once every driving test is green, take each verification test in turn:

1. Name the driving tests that should make it pass, and predict that it passes. Then remove its skip, write its body, and run it.
2. If it passes, record `Test already passes -- no production change needed.` and continue. A test that changed no code needs no refactor.
3. If it fails, the split was wrong. Record the prediction as `Incorrect`, leave the test active, and run a full cycle for it.

## Prediction miss

1. Record both outcomes. The miss stays `Incorrect`.
2. Stop feature work and apply the miss rule in `checkpoints.md`.
3. Find the cause with the smallest check: existing behavior, test setup, environment (containers, clock, shared fixture), build, coupling, or a regression.
4. Predict again and check. Resume once the miss is explained.

Change production behavior only for a cause you have explained.
