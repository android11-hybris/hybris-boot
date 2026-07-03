# Dynamic Partitions

Android 10 introduced dynamic partitions.

Android 11 relies heavily on them.

## Components

super

contains:

- system
- vendor
- product
- system_ext

logical partitions are created during boot.

## Modernization Goals

Support:

- slotselect
- logical
- metadata
- super
- AVB layouts

Avoid hardcoding block device paths whenever possible.
