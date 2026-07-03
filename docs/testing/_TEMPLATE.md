# Regression Verification: <topic>

- **Change:** <one-line description of the refactor>
- **Type:** Pure refactoring — no intended behavioural change.
- **Issue(s):** #<n>
- **Related design:** docs/design/<doc>.md

## Scope

<What was moved/reshaped, and what was deliberately left unchanged.>

## Equivalence checklist

### Build
- [ ] Relevant targets still build (`mka <targets>`).
- [ ] No new build warnings/errors.

### Deterministic outputs — byte-for-byte
- [ ] <output> identical (`cmp` / `diff`).

### Non-deterministic outputs — functional equivalence
(Bytes may differ only by timestamps/metadata; compare contents instead.)
- [ ] File list identical.
- [ ] Contents identical (`diff -r`).
- [ ] Permissions / ownership / symlinks identical.

### Structural / behavioural
- [ ] No content change to files that should be untouched.
- [ ] Legacy code paths unchanged.
- [ ] Original copyright/authorship preserved.

## Results

<What was actually run and the outcome.>

## Documented intentional deltas

<The only accepted differences from previous behaviour, each justified — or
"None.">

## Remaining validation (requires full build / device)

<Checks that need an Android build tree or a physical device.>

## Reproduction

```sh
<commands to re-run the local checks>
```
