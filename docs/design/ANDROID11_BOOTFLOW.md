# Android 11 Boot Flow

## Legacy Android

Bootloader

↓

boot.img

↓

kernel

↓

initramfs

↓

init

↓

Android

---

## Android 11+

Bootloader

↓

boot.img

↓

vendor_boot.img

↓

kernel

↓

first-stage init

↓

fstab.first_stage

↓

mount metadata

↓

mount vendor

↓

mount logical partitions

↓

switch_root

↓

second-stage init

↓

Android userspace

---

## Target hybris Flow

Bootloader

↓

boot.img

↓

vendor_boot.img

↓

kernel

↓

Android-compatible early initialization

↓

hybris adaptation layer

↓

Linux rootfs

↓

systemd
