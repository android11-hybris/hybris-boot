# Architecture

## Goal

Modernize hybris-boot for Android 11+ while preserving the original
Mer/Jolla architecture.

This project is an evolution—not a rewrite.

## Principles

- Preserve original functionality.
- Preserve authorship.
- Minimize invasive changes.
- Avoid distribution-specific behavior.
- Support multiple Linux distributions.
- **Capability-driven, never version- or device-driven** (see below).

## Core design principle: capability-driven build selection

The long-term design principle for the entire modernization effort is that the
build adapts to a device by **detecting build capabilities and board
configuration**, never by branching on an Android version number or a device
codename.

The build frontend detects features such as:

- boot header version,
- `vendor_boot` presence,
- `init_boot` presence,
- recovery-as-boot vs a dedicated recovery partition,
- GKI,
- DTB / DTBO handling and location.

From those capabilities it **resolves a build profile**. The frontend-independent
generation core (see `BOOT_GENERATION.md`) is then handed the resolved profile
and remains **completely unaware of the platform** — it never inspects Android
versions or device names; it simply consumes the profile.

This boundary is what lets a single `mka hybris-boot` entry point support:

- legacy devices,
- Android 11/12 devices (e.g. Pixel 5a / barbet),
- Android 13+ devices with `init_boot`,
- and future devices such as the Pixel 9 Pro Fold,

**without introducing any device-specific logic**. New hardware is supported by
detecting its capabilities, not by adding conditionals for its version or name.
Version numbers may appear in documentation as informal context, but must never
be a decision input in the build.

See `BOOT_IMAGE_SELECTION.md` for how this principle is applied to image
selection.

## Supported Platforms

- Sailfish OS
- Droidian
- Ubuntu Touch
- LuneOS
- Future libhybris systems

## Reference Device

Google Pixel 5a (barbet)

Android Base:
LineageOS 19.1

Kernel:
4.19

Halium:
12

## Major Modernization Areas

- boot header v3/v4
- vendor_boot
- first-stage init
- dynamic partitions
- logical partitions
- GKI
- improved debugging
