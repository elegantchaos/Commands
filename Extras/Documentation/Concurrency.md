# Concurrency

`Commands` coordinates application actions and their UI state on the main
actor. This keeps synchronous availability checks, command lifecycle tracking,
undo history, and SwiftUI presentation consistent.

## Command execution

`Command.perform(centre:from:)` is asynchronous so commands can await I/O and
other asynchronous services. Suspending for I/O does not block the main actor.
Keep synchronous work in a command short; move CPU-intensive work into an
injected `Sendable` service with an explicitly `@concurrent` operation.

Commands, command centres, inverse commands, and `UndoService` are intentionally
main-actor isolated. They may hold UI state and should not be transferred across
actor boundaries. Small immutable values that cross those boundaries, such as
`CommandSource`, `CommandAvailability`, `CommandError`, and
`CommandConfirmation`, conform to `Sendable`.

## Fire-and-forget execution

`performWithoutWaiting(_:from:)` starts an unstructured task and returns its
handle. It logs failures because callers may intentionally discard that handle.
Use `perform(_:from:)` when a caller needs the result, error, or task lifetime.

Commands do not provide a general cancellation mechanism. Applications should
model a long-running operation and its explicit cancel command in the way that
best fits that operation's domain.

## Undo and redo

`UndoService` is main-actor isolated and serializes history operations. While
undo or redo awaits an inverse command, an `UndoableCommandCentre` disables and
rejects new forward commands. This prevents main-actor reentrancy from changing
the history cursor during a suspended history operation. The matching undo or
redo command is allowed to complete and replaces the history entry with its
returned inverse.

`CommandCentre.isAllowed(from:)` lets a centre define an execution policy.
`UndoableCommandCentre` owns the history-specific rule: it blocks non-history
sources while its undo service has an active operation.

## Future option

If a future client needs commands that are independent of UI state and execute
across arbitrary actors, a separate non-UI `CommandsCore` layer could model
`Sendable` operations and results. The current package does not need that split:
its main-actor model keeps application command state and UI presentation simple.
