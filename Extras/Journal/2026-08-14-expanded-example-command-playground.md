# 2026-08-14 — Expanded example command playground

## Summary

Expanded the example application into a shared command playground that exposes
the same command state through menus, toolbars, contextual menus, and standard
buttons on macOS and iOS.

## Completed work

- Added reversible add and remove commands with disabled availability at the
  lower and upper item limits.
- Added a confirmable clear command and an importer-backed text-file command,
  including the modifier-based contextual-menu importer integration.
- Added an advanced command that is initially hidden, then disabled or enabled
  according to the current completed-item count.
- Added command menus, toolbars, localised state presentation, and a concise
  README description of the expanded example.
