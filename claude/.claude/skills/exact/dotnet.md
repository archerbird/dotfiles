# .NET stack: xUnit, Moq, FluentAssertions

Use what the repo already uses. Before writing a test, read a neighbouring test file and follow its fixtures, builders, naming, and assertion style.

## Inactive tests

- Driving: `[Fact(Skip = "driving")]`
- Verification: `[Fact(Skip = "verification: relies on <TestA>, <TestB>")]`
- A `[Theory]` takes the same `Skip`, with its data attributes in place.

The skip reason carries the group, so activating a test means deleting its `Skip` argument and nothing else remains. File order is list order. When the list is done, grep the test files to confirm that no `Skip = "driving"` or `Skip = "verification` is left.

## Commands

Find the solution, the test projects, and any prerequisites (containers, environment variables) in the repo's README, CLAUDE.md, or CI pipeline. When integration tests need containers, check that they are running before you predict.

- **Focused run** (Red, Green, each refactoring): `dotnet test <test project> --filter "FullyQualifiedName~<Class>.<Method>"`. This is the xUnit v2 VSTest syntax; under Microsoft Testing Platform, use the filter the repo documents.
- **Close gates**: build the solution with no new warnings, then run every test project the change touches and any architecture-test project.
- **Task end**: the full suite.

## Predicting outcomes

- A skipped test counts as skipped, never as passed.
- A test that reads the wall clock, or shares a fixture clock with other tests, passes or fails by date. Pin the clock the repo's way before predicting its outcome.
- When a strict Moq mock or a `Verify` is the assertion, predict the Moq exception and its message.
- FluentAssertions failures name the expected and actual values; predict both.

## Style

`csharp-style.md` applies to tests and production code alike. Test names are spec sentences in PascalCase, as the repo writes them.
