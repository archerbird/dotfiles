# Checkpoints

The level is the `/exact` argument. With none, it is `refactor-only`.

| Level | Stops after |
| --- | --- |
| `full-hitl` | each Red and each Refactor |
| `refactor-only` | each Refactor |
| `red-only` | each Red |
| `every-n-tests N` | every N completed cycles |
| `task-end` | the end of the workflow |
| `autonomous` | never |

Every level stops after the Test List. Every level stops on a prediction miss except two: `task-end` reports misses at the end, and `autonomous` investigates and resumes.

At a stop, show the evidence and wait for explicit approval:

- **Test List:** the driving tests in order, the verification tests with the driving tests each relies on, the coverage cross-check, and the readings adopted for open contracts.
- **Red:** the active test, both predictions with their outcomes, and why this failure is the intended red.
- **Refactor:** the Four Rules decision, the boundary records, the architecture placement, the changes made, and the gates passed.
- **Prediction miss:** predicted against actual. Then ask whether to investigate or continue.

A one-word approval continues to the next stop. Carry out instructions given at a stop, such as a rename or a different placement, as refactorings with predictions before continuing.
