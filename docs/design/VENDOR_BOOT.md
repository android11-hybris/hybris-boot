# vendor_boot

## Background

Android 11 introduced vendor_boot.img.

boot.img no longer contains everything required for boot.

## vendor_boot Contains

- vendor ramdisk
- first_stage_ramdisk
- kernel modules
- DTB
- vendor fstab

## Pixel 5a

DTB resides inside vendor_boot.

first_stage_ramdisk contains:

fstab.sm7250

Kernel modules required during early boot are loaded from vendor_boot.

## Goals

hybris-boot must understand:

- boot header v3
- vendor ramdisk
- DTB location
- vendor modules

without assuming legacy boot.img layouts.
