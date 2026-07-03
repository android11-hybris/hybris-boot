# First Stage Init

## Legacy hybris-boot

kernel

↓

initramfs

↓

hybris init

↓

switch_root

---

## Android 11

kernel

↓

first-stage init

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

---

## Modernization Goal

Determine whether hybris should:

1. integrate with Android first-stage init

or

2. replace it while preserving required functionality.

The preferred solution should minimize compatibility risks.
