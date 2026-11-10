---
name: exact
description: Build agreed behavior test-first with EXACT Coding, predictive Red-Green-Refactor one test at a time. Pass a phase (red, green, refactor) to run only that phase, or an autonomy level.
argument-hint: "[red|green|refactor] [autonomy level]"
disable-model-invocation: true
---

# EXACT: predictive Red-Green-Refactor

Build behavior that is already agreed, usually by `/kickoff`, one test at a time. Before every test run you write a falsifiable **prediction**; a miss is evidence and stops feature work. The method is EXACT Coding (Emrich and Ade, github.com/marcoemrich/EXACT-Coding v1.2), with its Refactor phase extended by the .NET taxonomy.

Arguments: `$ARGUMENTS`

- A phase (`red`, `green`, `refactor`): run only that phase, then stop.
- An autonomy level from `checkpoints.md`: run the whole workflow at that level. With no level, use `refactor-only`.

## Read first

From this skill's folder, `~/.claude/skills/exact/`:

- `cycle.md`: the predictive cycle, binding as written.
- `checkpoints.md`: when to stop and what to show.
- `dotnet.md`: inactive-test syntax, commands, and gates.
- `test-list.md`: how to build and write the test list.

Also `~/.claude/rules/dotnet-architecture.md`, which the Refactor phase places code by.

## Whole workflow

1. **Spec.** Find the agreed behavior: the kickoff summary in this conversation, the Jira ticket it was posted to, or a spec the user names. If there is none, say so and suggest `/kickoff`.
   Done when every example you will build has an agreed, exact outcome.
2. **Test list.** If the skipped tests are not already in the code, build and write them by `test-list.md`. Predict and run the build and the affected test projects: everything compiles and the new tests report as skipped. Stop at the Test List checkpoint.
3. **Driving part.** For each driving test in list order, run one cycle from `cycle.md`, stopping where `checkpoints.md` says for the active level.
4. **Verification part.** Activate the verification tests one at a time, as `cycle.md` describes.
5. **Architecture review.** Dispatch the `dotnet-architecture-reviewer` agent on the branch diff. Present its findings, and apply only those the user accepts, each as a refactoring with a prediction.

Done when every test in the list is active and green, the task-end gates in `dotnet.md` pass, every prediction miss is explained, and nothing beyond the agreed examples was built.

## Single phase

Run only the named phase from `cycle.md`. Then report what that phase's checkpoint shows and stop, whatever the autonomy level: invoking the phase is the checkpoint.

- `red`: needs a test list. If none exists, offer to build one first. Choose and activate the next test, and reach behavioral red.
- `green`: needs an active red test. If the suite is green, say so and offer `red` or `refactor`.
- `refactor`: needs green. If anything is red, offer `green`.
