# hybris-boot Android 11+ Modernization Project

## Vision

Modernize the original hybris-boot project to support Android 11 and newer devices while preserving the original architecture and development philosophy.

This project is intended to extend—not replace—the original Mer/Jolla hybris-boot implementation.

The modernization should remain useful for multiple Linux distributions including:

- Sailfish OS
- Droidian
- Ubuntu Touch
- LuneOS
- Other libhybris-based operating systems

---

# Design Goals

## Preserve Existing Architecture

The original design has proven itself for many years.

Whenever practical:

- extend existing code
- avoid rewrites
- preserve project history

---

## Support Modern Android

Support modern Android boot architecture including:

- Android 11+
- Android 12
- Android 13
- Android 14
- Android 15
- Android 16

Features include:

- vendor_boot
- boot header v3/v4
- Generic Kernel Image (GKI)
- first-stage init
- logical partitions
- dynamic partitions
- AVB 2.x
- metadata partition

---

## Generic Adaptation Layer

This project should remain distribution-neutral.

Avoid introducing Ubuntu Touch, Droidian or Sailfish specific behavior unless it can be made optional.

---

## Development Principles

- Keep commits small.
- Keep patches reviewable.
- Preserve upstream compatibility.
- Document behavioral changes.
- Avoid unnecessary complexity.

---

## Reference Device

Current development is performed using:

Google Pixel 5a (barbet)

Android Base:

LineageOS 19.1

Kernel:

Linux 4.19

Halium:

12
