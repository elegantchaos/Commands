# Concurrency

`Commands` coordinates application actions and their UI state on the main
actor. This keeps synchronous availability checks, command lifecycle tracking,
undo history, and SwiftUI presentation consistent.

## Command execution

`Command.perform(centre:)` is asynchronous so commands can await I/O and
other asynchronous services. Suspending for I/O does not block the main actor.
Keep synchronous work in a command short; move CPU-intensive work into an
injected `Sendable` service with an explicitly `@concurrent` operation.

Commands, command centres, inverse commands, and `UndoService` are intentionally
main-actor isolated. They may hold UI state and should not be transferred across
actor boundaries. Small immutable values that cross those boundaries, such as
`CommandAvailability`, `CommandError`, and `CommandConfirmation`, conform to
`Sendable`.

## Fire-and-forget execution

`performWithoutWaiting(_:)` starts an unstructured task and returns its
handle. It logs failures because callers may intentionally discard that handle.
Use `perform(_:)` when a caller needs the result, error, or task lifetime.

Commands do not provide a general cancellation mechanism. Applications should
model a long-running operation and its explicit cancel command in the way that
best fits that operation's domain.

## Undo and redo

`UndoService` is main-actor isolated and serializes history operations. An
`UndoableCommandCentre` tracks active forward commands and does not start undo
or redo until they finish. While undo or redo awaits an inverse command, it
disables and rejects new forward commands. This prevents main-actor reentrancy
from changing the history cursor during a suspended history operation. The
matching undo or redo command is authorised through an opaque
`CommandExecutionContext` owned by its `UndoService` and replaces the history
entry with its returned inverse.

`CommandExecutionContext` is a generic capability: `CommandCentre` has no
undo or redo knowledge. `UndoableCommandCentre` owns the history-specific rule:
while its undo service has an active operation, it allows only the context owned
by that service.

The service owns the context and all active-operation state. Do not use global,
static mutable, or task-scoped state to authorize history execution. The active
mode and its context are represented by one private value, so neither can exist
without the other. Inverse implementations must use the supplied context only
for their invocation and must not retain it.

Forward commands can overlap, so an undo service tracks them with a count rather
than treating them as another history-operation mode. Undo and redo wait until
that count reaches zero; while either history operation is suspended, new
forward commands are disabled and rejected. This protects the history cursor
from main-actor reentrancy.

If an undoable centre replaces the default `recordStartedCommand` or
`recordFinishedCommand` implementations, it must call
`undoService.beginForwardCommand()` and `undoService.finishForwardCommand()`
for every forward command.

## Future option

If a future client needs commands that are independent of UI state and execute
across arbitrary actors, a separate non-UI `CommandsCore` layer could model
`Sendable` operations and results. The current package does not need that split:
its main-actor model keeps application command state and UI presentation simple.
