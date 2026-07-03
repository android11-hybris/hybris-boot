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
