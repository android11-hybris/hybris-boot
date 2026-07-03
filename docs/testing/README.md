# Testing & Regression Verification

This directory holds the project's **regression verification records** and the
convention that governs them.

## Why this exists

The Android 11+ modernization deliberately proceeds as a series of small,
reviewable changes (see the project philosophy). Much of the early work is
**behaviour-preserving refactoring** — reshaping the code so that later, riskier
features (vendor_boot, first-stage init, dynamic partitions) can be added
cleanly. A refactor that silently changes behaviour is a regression, and
regressions in boot code are expensive to debug on real hardware.

## Project convention

> **Every behaviour-preserving refactor must ship with an explicit regression
> verification record in `docs/testing/`, and its commit / pull request must
> summarise what was verified.**

A change is "behaviour-preserving" if it is intended to produce the same result
as before (same generated files, same images, same runtime behaviour). For such
changes:

1. State clearly that the change is a **pure refactoring with no intended
   behavioural change**.
2. Add or update a regression record here (one file per change/topic).
3. Reference the record from the commit message and PR description.
4. List any validation that could **not** be performed locally (e.g. a full
   Android build or an on-device boot test) so reviewers know what remains.

Feature changes (which intentionally change behaviour) do not need an
equivalence record, but should still describe how they were tested.

## What a regression record must contain

- **Scope** — what was refactored, and the issue it addresses.
- **Equivalence class** for each output:
  - **Byte-for-byte** where the output is deterministic (no timestamps/metadata).
  - **Functional equivalence** where bytes legitimately differ (e.g. cpio/gzip
    embed mtimes) — compare contents, permissions, symlinks, structure instead.
- **Results** — the concrete checks that were run and their outcome.
- **Documented intentional deltas** — the only accepted differences from the
  previous behaviour, each with a justification.
- **Remaining validation** — checks that require a full Android build tree or a
  physical device, to be run on a build host / reference device.
- **Reproduction** — commands so a contributor or CI can re-run the checks.

## Template

Copy [`_TEMPLATE.md`](_TEMPLATE.md) to a new `docs/testing/<topic>.md` for each
behaviour-preserving refactor.

## Records

- [`boot-generation-core.md`](boot-generation-core.md) — extraction of the
  frontend-independent boot generation core (issue #1).
