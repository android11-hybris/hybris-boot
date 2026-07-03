# Boot Architecture

## Original hybris-boot

The original hybris-boot architecture targeted Android devices using a traditional boot.img and static partition layout.

Boot Flow

Bootloader

↓

Kernel

↓

hybris initramfs

↓

Mount Android userdata

↓

Bind Linux root filesystem

↓

switch_root

↓

Linux userspace

---

## Modern Android

Android 11 introduced major architectural changes.

Modern boot flow typically becomes:

Bootloader

↓

boot.img

↓

vendor_boot.img

↓

Android first-stage init

↓

Mount logical partitions

↓

Mount vendor

↓

Mount metadata

↓

Load vendor kernel modules

↓

Launch adaptation layer

↓

Switch to Linux userspace

---

## Modernization Goals

Modernize hybris-boot while preserving its debugging capabilities.

Retain:

- init.log
- USB networking
- telnet console
- command injection
- debugging utilities

Support:

- vendor_boot
- GKI
- boot header v3/v4
- logical partitions
- dynamic partitions
- metadata
- Android first-stage init

---

## Long-Term Goal

Provide a generic adaptation layer suitable for Android 11+ devices regardless of Linux distribution.
