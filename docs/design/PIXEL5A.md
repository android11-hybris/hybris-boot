# Pixel 5a (barbet)

Reference platform for development.

## SoC

Qualcomm SM7250

## Android

LineageOS 19.1

Android 12

## Boot Header

Version 3

## DTB

Stored inside vendor_boot.img

## DTBO

Must match kernel DTB.

Stock dtbo + custom kernel DTB causes early boot failure.

## Dynamic Partitions

Uses super.

Logical partitions:

- system
- vendor
- product
- system_ext

## Recovery

Recovery-as-boot.

No dedicated recovery partition.

## vendor_boot

Contains:

- DTB
- first_stage_ramdisk
- vendor modules

## Current Status

✔ hybris-boot builds

✔ vendor_boot builds

✔ system.img builds

Next objective:

Boot to early debug shell.
