---
paths:
  - "**/*.cs"
---

# C# style

- Every `if`, `else`, `for`, `foreach`, `while`, and `do` body goes in braces, one-liners included.
- A single-implementation interface lives in the same file as its class (`FooEngine.cs` holds `IFooEngine` and `FooEngine`). Give the interface its own file only when several implementations exist at once, or when it lives in another project (Data Accessor interfaces in Core, implementations in Infrastructure). When touching an existing `IFoo.cs` + `Foo.cs` pair, merge them.
- Type a local as `var` or its concrete type when the concrete instance is in hand. Interface types belong on parameters, fields, and DI registrations. Concrete (especially `sealed`) references let the JIT devirtualize.
- Use an existing property directly; add a new property only when it computes something different.
- Duration settings: name them `...Duration` and write ISO 8601 values in config (`"StaleJobDuration": "PT4H"`).
- Options classes consumed across layers live in Core.
- Cross-cutting concerns around a Data Accessor (caching, metrics, retries): a decorator implementing the same interface, wired in DI, so callers never see it. Keep the interface implementation-agnostic, with no members that exist only for the decorator. Cross-cutting reactions to a state change: raise an event and handle it in a Listener.
