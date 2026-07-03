# Boot Generation Core

## Purpose

The logic that turns the hybris sources (`init-script`, `initramfs/`,
`fixup-mountpoints`, a kernel and a static busybox) into `hybris-boot.img`
and `hybris-recovery.img` used to live inline in the `Android.mk` recipes.

This document describes the **frontend-independent boot generation core**
extracted in issue #1.

## Two frontends, one core

```
        Android.mk  (today)            Android.bp / Soong  (possible future)
             \                                 /
              \                               /
               v                             v
        scripts/generate-init.sh   (template init-script + fixup-mountpoints)
        scripts/generate-ramdisk.sh(assemble cpio + gzip/lz4)
        scripts/generate-bootimg.sh(invoke mkbootimg)
```

The build **frontend** is responsible only for *computing inputs* (device
partitions, kernel path, mkbootimg args from board config). The **core**
scripts take those inputs explicitly as arguments and contain no dependency
on make internals, so a Soong `genrule` could call the identical scripts.

This keeps the project build-system agnostic (see the project decision
recorded in the docs) without converting away from `Android.mk` or
duplicating build logic.

## Scripts

### `scripts/generate-init.sh`
```
generate-init.sh SRC OUT DATA_PART BOOTLOGO DEFAULT_OS ALWAYSDEBUG FIXUP_MOUNTS TARGET_DEVICE
```
Templates the `%DATA_PART%`, `%BOOTLOGO%`, `%DEFAULT_OS%`, `%ALWAYSDEBUG%`
placeholders in `init-script` (identical `sed` expressions to the original
recipe), then applies `fixup-mountpoints` for the target device and marks
the result executable.

### `scripts/generate-ramdisk.sh`
```
generate-ramdisk.sh SRC_DIR INIT BUSYBOX OUT WORKDIR COMPRESS [LZ4]
```
Stages `initramfs/`, moves the generated `init` into place, drops in the
static busybox, and produces a `newc` cpio compressed with `gzip -9`
(default) or `lz4` (`COMPRESS=lz4`). The `mv` of `init` is deliberate and
preserves the original recipe's "rebuild init every time" behaviour.

### `scripts/generate-bootimg.sh`
```
generate-bootimg.sh MKBOOTIMG OUTPUT [mkbootimg args...]
```
Thin wrapper that runs `mkbootimg` with the frontend-supplied arguments and
writes `OUTPUT`. Argument computation stays in the frontend.

## Scope / non-goals

This is a **refactoring**, not a feature addition. It introduces no new boot
capability (no header v3/v4, vendor_boot, etc. — those are separate issues).
Output must remain equivalent to the pre-refactor build.


## Regression verification

This refactoring is verified equivalent to the previous inline recipes. The
permanent regression record — checklist, results, intentional deltas, remaining
build/device validation, and reproduction commands — lives at
[`docs/testing/boot-generation-core.md`](../testing/boot-generation-core.md).

Per project convention, every behaviour-preserving refactor carries such a
record; see [`docs/testing/README.md`](../testing/README.md).
