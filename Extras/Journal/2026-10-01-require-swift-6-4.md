# 2026-10-01 — Require Swift 6.4

## Summary

Raised the package's minimum to Swift 6.4: `swift-tools-version`, the README
badge, and the CI workflow (iOS and watchOS select an Xcode whose Swift is 6.4,
preferring 27.0; the macOS job selects Swift 6.4; the job ids and names say
`swift64`).

## Why

SwiftPM's own build system, in Swift 6.3, does not compile string catalogs, so a
lookup of a catalog string returns its key. A test of the stock confirmation
strings failed in CI for that reason while passing locally, where the unified
build system was in use. Swift 6.4 uses the unified build system, so catalogs
compile everywhere the package builds.

## Consequences

- Apps that depend on Commands need a Swift 6.4 toolchain (Xcode 27) when they
  take this change. Bookish already builds with it; ActionStatus and Stack
  would need to move first.
- The CI check names change with the job names. Anything that requires a check
  by its old name ("... (Swift 6.3 ...)") needs updating.
- Added a test that the stock strings resolve to their English text, next to the
  existing one that checks the catalog source.

## Not verified

CI had to find an Xcode 27 and a `setup-swift` that supports 6.4 on its runners;
that was proven only by the CI run for this change.
