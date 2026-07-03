# Boot Image Selection

## Purpose

Modern Android devices no longer share a single boot-image layout. The build
must **detect the device's boot architecture and emit the correct set of images
automatically**, so that a single command —

```
mka hybris-boot
```

— produces working images whether the device is a legacy header v0–v2 board with
a dedicated recovery partition, or a modern header v3/v4 board that uses
`vendor_boot`, recovery-as-boot, and (Android 13+) `init_boot`.

This is a **generic build-system capability**, not a per-device workaround. The
Pixel 5a (barbet) is the reference implementation, but nothing in the selection
logic may key off a device codename.

## Detected capabilities

Selection is keyed on **capabilities**, not on Android version numbers or device
names. The frontend detects a set of independent features and resolves a profile
from their combination:

- boot header version (a value, e.g. 2 / 3 / 4);
- `vendor_boot` present;
- `init_boot` present;
- recovery-as-boot vs a dedicated recovery partition;
- GKI;
- DTB location / DTBO handling.

Because these are orthogonal capabilities rather than version buckets, new
hardware combinations are supported automatically — the frontend does not need
to recognise the platform, only its capabilities.

## Capability combinations (illustrative)

The rows below are common combinations. **The Android version column is context
only — it is never a decision input.** Selection is driven purely by the
capability columns.

| Capabilities | (context: Android) | Recovery | Vendor ramdisk / first-stage |
|---|---|---|---|
| header v0–v2, no vendor_boot | legacy | dedicated recovery partition | in boot ramdisk |
| header v3, vendor_boot, recovery-as-boot | 11/12 — **barbet** | recovery-as-boot | `vendor_boot.img` (DTB, first_stage_ramdisk, modules) |
| header v4, vendor_boot, init_boot, recovery-as-boot | 13+ | recovery-as-boot | `vendor_boot.img` + generic ramdisk in `init_boot.img` |

## Reference device: Pixel 5a (barbet)

- Boot header **v3**.
- **No dedicated recovery partition** — recovery is served through the normal
  `boot.img` flow (recovery-as-boot).
- **`vendor_boot.img`** carries the DTB, `first_stage_ramdisk`, and
  device-specific early kernel modules.

The current code still assumes the legacy model (separate `hybris-boot` and
`hybris-recovery` images, and an existing recovery partition). On barbet that
produces a wrong/orphan recovery image and an incorrectly-formatted boot image.

## Detection

Selection must be driven by **board configuration**, never by device name. The
build already has access to the relevant AOSP/LineageOS board variables; the
implementation will derive a "boot profile" from them. Candidate inputs
(exact names to be confirmed against the target build during implementation):

- boot header version (e.g. `BOARD_BOOT_HEADER_VERSION`);
- whether a `vendor_boot` image is built (e.g. `BUILDING_VENDOR_BOOT_IMAGE` /
  `BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT`);
- recovery-as-boot / no-recovery-partition
  (e.g. `BOARD_USES_RECOVERY_AS_BOOT`, `BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE`,
  absence of a recovery partition in the fstab — see partition discovery);
- GKI (e.g. `BOARD_USES_GENERIC_KERNEL_IMAGE`);
- `init_boot` presence (Android 13+).

## Selection logic (capabilities → profile → outputs)

| Capabilities | Images produced | mkbootimg behaviour |
|---|---|---|
| header ≤ 2, no vendor_boot, recovery partition | `hybris-boot` + `hybris-recovery` | header ≤ 2 args (current) |
| header v3, vendor_boot, recovery-as-boot | `hybris-boot` (+ `vendor_boot`); **no** separate recovery image | header v3, split ramdisk, DTB in vendor_boot |
| header v4, vendor_boot, init_boot, recovery-as-boot | `hybris-boot` / `init_boot` (+ `vendor_boot`) | header v4 |

## Frontend / core boundary

- The **frontend** detects capabilities from board configuration and **resolves
  a profile** (a plain description of what to build and how).
- The **generation core is platform-unaware**: it receives the resolved profile
  and consumes it. It never inspects Android versions, device names, or board
  variables. See `BOOT_GENERATION.md`.
- A future Soong frontend performs the same capability detection and hands the
  same kind of profile to the same core.

This is the applied form of the project's core design principle (see
`ARCHITECTURE.md`): **capability-driven, never version- or device-driven.**

## Design principles

- **Capability-driven** — profiles are resolved from detected features, not from
  Android version numbers or device codenames. No `ifeq TARGET_DEVICE = barbet`
  conditionals anywhere.
- **Platform-unaware core** — the generation core only sees the resolved profile.
- **Legacy preserved** — devices whose capabilities match the legacy profile
  build exactly as before.
- **One entry point** — `mka hybris-boot` yields the correct image set; the
  separate recovery image is emitted only when the device actually has a
  recovery partition.
- **Forward-compatible** — future devices (e.g. Pixel 9 Pro Fold) are supported
  by detecting their capabilities, with no new device-specific logic.

## Implementation tracking

This architecture is implemented across the build-system issues:

- header v3/v4 + GKI image assembly;
- build & populate `vendor_boot.img`;
- recovery-as-boot (skip the separate recovery image when there is no recovery
  partition);
- and a coordinating issue for the detection / image-set selection itself.

## Status

Planned — milestone **v0.3 (Modern boot image support)**. Gated behind the
current build-system refactor being validated on a real build and on barbet.
