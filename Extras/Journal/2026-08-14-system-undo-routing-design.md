# 2026-08-14 — System undo routing design

## Summary

Recorded the proposed routing design for integrating `UndoService` with the
system Undo and Redo commands without bridging asynchronous command reversals
into Foundation's synchronous `UndoManager`.

## Design direction

- Native text editing retains ownership of its framework `UndoManager`.
- Application command reversals use the active scene's `UndoService` only when
  there is no native editing context.
- macOS and iPadOS 26 require focused platform prototypes before the routing
  adapter becomes a public `CommandsUI` API.
