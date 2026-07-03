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

## Boot architectures to support

| Architecture | Boot header | Recovery | Vendor ramdisk / first-stage | Notes |
|---|---|---|---|---|
| Legacy | v0–v2 | dedicated recovery partition | in boot ramdisk | current hybris-boot assumption |
| Android 11/12 GKI | v3 | recovery-as-boot | `vendor_boot.img` (DTB, first_stage_ramdisk, modules) | **barbet** |
| Android 13+ GKI | v4 | recovery-as-boot | `vendor_boot.img` + generic ramdisk in `init_boot.img` | |

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

## Selection logic (profile → outputs)

| Detected profile | Images produced | mkbootimg behaviour |
|---|---|---|
| Legacy | `hybris-boot` + `hybris-recovery` | header ≤ 2 args (current) |
| Recovery-as-boot, header v3 | `hybris-boot` (+ `vendor_boot`); **no** separate recovery image | header v3, split ramdisk, DTB in vendor_boot |
| Recovery-as-boot, header v4 (A13+) | `hybris-boot` / `init_boot` (+ `vendor_boot`) | header v4 |

## Design principles

- **Detection lives in the build frontend**, and feeds the frontend-independent
  boot generation core (see `BOOT_GENERATION.md`, added by the build-system
  refactor). A future
  Soong frontend performs the same detection and calls the same core.
- **Generic, board-driven** — no `ifeq TARGET_DEVICE = barbet` conditionals.
- **Legacy preserved** — devices detected as legacy build exactly as before.
- **One entry point** — `mka hybris-boot` yields the correct image set; the
  separate recovery image is emitted only when the device actually has a
  recovery partition.

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
