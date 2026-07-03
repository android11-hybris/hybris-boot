# Boot Generation Validation Runbook

This is the project's **canonical validation procedure for any change that
affects boot generation** — `Android.mk` / build frontend, the generation core
under `scripts/`, `init-script` templating, ramdisk assembly, image selection,
vendor_boot / init_boot handling, or mkbootimg invocation.

Pull requests that touch boot generation should reference this document, and
regression verification records under `docs/testing/` should point here for the
build/device portion of their checks. See `README.md` for the regression-record
convention and `_TEMPLATE.md` for the record template.

## Guiding principle: validate the resolved profile, not the version

Validation is **capability-driven, not version-driven** (see
`../design/ARCHITECTURE.md` and `../design/BOOT_IMAGE_SELECTION.md`). Always
determine the device's *capabilities* first, then run the checks that apply to
the profile those capabilities resolve to. Do not assume checks from an "Android
version"; a device is validated against what it actually is
(header version, vendor_boot, init_boot, recovery-as-boot, etc.).

## Prerequisites

- **Build environment**: a working LineageOS / Halium tree for the target device,
  with `source build/envsetup.sh` and the device selected (`lunch` / `breakfast`).
- **Reference devices** (use the one(s) matching the profile you changed):
  - a **legacy** device (header <= 2, dedicated recovery partition);
  - an **Android 11/12 vendor_boot** device — **Pixel 5a (barbet)** is the
    project reference;
  - an **Android 13+ init_boot** device (when available).
- **Tools**:
  - `unpack_bootimg` (AOSP `system/tools/mkbootimg`) — preferred; or
    `unpackbootimg`;
  - `mkbootimg` (for reference/diffing);
  - `cpio`, `gzip`, `lz4` (ramdisk extraction; legacy lz4 uses `lz4 -l`);
  - `avbtool` (AVB / vbmeta handling — see the AVB issue);
  - `dtc` (device-tree compiler, for DTB/DTBO inspection);
  - `cmp`, `diff`, `file`, `xxd`/`od`, `python3`.
- **Baseline**: build the images from the **pre-change commit** first and keep
  them, so "after" can be compared against "before". Functional equivalence is
  judged against this baseline.

## Step 0 — Determine device capabilities

Before building, record the device's boot capabilities (from the device
`BoardConfig*.mk` / build variables / an existing stock image). These select
which sections below apply:

- boot header version;
- `vendor_boot` present?
- `init_boot` present? (Android 13+)
- recovery-as-boot, or a **dedicated recovery partition**?
- GKI?
- DTB location (in `vendor_boot`? separate `dtb.img`? in-kernel?) and DTBO
  (`dtbo.img`) handling.

## Step 1 — Build

Single entry point (always):

```
mka hybris-boot
```

Additional targets **by capability**:

- **Dedicated recovery partition present** (legacy profile): also
  ```
  mka hybris-recovery
  ```
  On **recovery-as-boot** devices, a separate recovery image must **not** be
  produced — its absence is expected and correct.
- **vendor_boot present**: the device's image set includes `vendor_boot.img`
  (built as part of the normal flow). Confirm it was produced.
- **init_boot present** (A13+): confirm `init_boot.img` was produced.

## Step 2 — Unpack and compare against baseline

For each produced image, unpack both the baseline and the new image and compare:

```
unpack_bootimg --boot_img $OUT/hybris-boot.img --out /tmp/after-boot
unpack_bootimg --boot_img $BASELINE/hybris-boot.img --out /tmp/before-boot
```

Compare:

- **kernel** — byte-identical (the refactor must not alter the kernel);
- **cmdline** — identical;
- **header version** — matches the device capability;
- **page size / offsets** — identical to baseline;
- **ramdisk** — functional equivalence: extract the cpio from both and
  `diff -r` the trees (raw compressed bytes differ only by cpio/gzip mtimes).

## Step 3 — Per-artifact verification

### boot.img (all profiles)
- [ ] kernel matches baseline
- [ ] cmdline matches baseline
- [ ] header version correct for the device
- [ ] ramdisk contents / permissions / symlinks equivalent to baseline

### vendor_boot.img (capability: vendor_boot)
```
unpack_bootimg --boot_img $OUT/vendor_boot.img --out /tmp/after-vendor
```
- [ ] vendor ramdisk present; `first_stage_ramdisk` content as expected
- [ ] **DTB present** in vendor_boot and correct
- [ ] vendor cmdline as expected
- [ ] early kernel modules present
- [ ] header version correct

### DTB / DTBO
- [ ] DTB decompiles (`dtc`) and matches the expected board
- [ ] `dtbo.img` (if present) is consistent with the kernel DTB (a stock DTBO
      with a custom kernel DTB causes early boot failure — see `../design/PIXEL5A.md`)

### init_boot.img (capability: init_boot, A13+)
- [ ] generic ramdisk present and contains `init`
- [ ] header version correct (v4)

## Step 4 — Boot smoke test

Prefer a **non-destructive** boot first:

```
fastboot boot hybris-boot.img -c bootmode=debug
```

Handle verified boot as documented (AVB / vbmeta) before flashing persistently.

- [ ] Device reaches the **same point as the baseline** (early debug shell via
      telnet, or `switch_root`), i.e. no regression in how far boot progresses.

## Mandatory vs optional checks

**Mandatory for every boot-generation change:**
- Build succeeds for the device's resolved profile (Step 1).
- Generated `init` is byte-for-byte identical where deterministic, or
  functionally equivalent where it is not.
- Ramdisk contents/permissions/symlinks equivalent to baseline (Step 2/3).
- boot.img kernel + cmdline + header version verified (Step 3).
- Boot smoke test on at least the reference device for the **affected** profile
  (Step 4).
- For `vendor_boot`/`init_boot` changes: the corresponding per-artifact section.

**Optional / device-specific:**
- Cross-profile validation on additional devices beyond the affected profile.
- Exact DTBO matching and DTB board specifics (device-specific).
- lz4 vs gzip ramdisk variants where only one is used by the device.
- Performance / image-size comparisons.

## Expected differences by profile (capability-driven)

Run the checks whose capability is present; do not key off the Android version.

| Resolved profile (capabilities) | Images to validate | Recovery expectation | Extra checks |
|---|---|---|---|
| header <= 2, no vendor_boot, recovery partition | `hybris-boot` + `hybris-recovery` | separate recovery image **present** | none beyond boot.img |
| header v3, vendor_boot, recovery-as-boot (**barbet**) | `hybris-boot` + `vendor_boot` | **no** separate recovery image | vendor_boot + DTB/DTBO |
| header v4, vendor_boot, init_boot, recovery-as-boot (A13+) | `hybris-boot`/`init_boot` + `vendor_boot` | **no** separate recovery image | vendor_boot + init_boot + DTB/DTBO |

## Recording results

- Reference this runbook from the pull request ("validated per
  `docs/testing/VALIDATION.md`") and record which profile was validated and on
  which device.
- In the change's regression record (`docs/testing/<topic>.md`), the
  build/device checks may cite this runbook rather than repeating the procedure;
  record the concrete results and any profile-specific notes.
