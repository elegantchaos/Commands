# Adopt Logger 3.0.0

Commands now requires Logger 3.0.0. Bookish is moving to Logger 3 for its channel menu, and a package graph can hold only one Logger major, so Commands' `from: "2.1.0"` would stop Bookish's packages resolving.

No source changed. `commandChannel` is still `Channel("Commands")`, which keeps the 3.0 default of disabled, and the `log` and `debug` calls are unchanged. `commandChannel` is public, so its type now comes from Logger 3; any consumer that also pins Logger 2 has to move too.

## Verification

`agt validate` passed: the package builds and its tests pass on macOS.
