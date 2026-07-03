# Regression Verification: boot generation core extraction

- **Change:** Extract the initramfs assembly, `init-script` templating, and
  `mkbootimg` invocation from the `Android.mk` boot/recovery recipes into
  frontend-independent helper scripts under `scripts/`.
- **Type:** Pure refactoring — **no intended behavioural change**.
- **Issue(s):** #1
- **Related design:** [`docs/design/BOOT_GENERATION.md`](../design/BOOT_GENERATION.md)

## Scope

Moved into the core (`scripts/generate-init.sh`, `scripts/generate-ramdisk.sh`,
`scripts/generate-bootimg.sh`):

- `%DATA_PART%` / `%BOOTLOGO%` / `%DEFAULT_OS%` / `%ALWAYSDEBUG%` templating and
  `fixup-mountpoints` application;
- initramfs staging, `init` + static busybox injection, cpio + gzip/lz4 packing;
- the `mkbootimg` call.

`Android.mk` remains the build frontend: it computes inputs (partitions, kernel,
board args) and calls the core. Deliberately unchanged: `init-script`,
`initramfs/`, `fixup-mountpoints`, `updater-script`, `updater-unpack.sh`.

## Equivalence checklist

### Build
- [ ] `mka hybris-boot` succeeds *(requires Android tree — see Remaining validation)*
- [ ] `mka hybris-recovery` succeeds *(requires Android tree)*
- [ ] `hybris-updater-script` / `hybris-updater-unpack` build *(requires Android tree)*
- [x] `Android.mk` recipe lines are tab-indented; make structure valid

### Deterministic outputs — byte-for-byte
- [x] Generated `init` identical — **boot** variant (`cmp`)
- [x] Generated `init` identical — **recovery** variant (`cmp`)
- [x] All four placeholders substituted identically, incl. empty values
- [x] `fixup-mountpoints` applied identically

### Non-deterministic outputs — functional equivalence
(cpio/gzip embed mtimes; the original recipe is already non-reproducible byte-wise.)
- [x] Ramdisk member list identical
- [x] Ramdisk contents identical (`diff -r`)
- [x] Permissions / types / symlinks identical
- [x] gzip magic correct; legacy LZ4 framing correct (`-l`, magic `0x184C2102`)

### mkbootimg argument forwarding
- [x] Arguments forwarded verbatim
- [x] Quoted `--cmdline "…"` preserved as a single argv element
- [x] `--output` appended (order-independent for mkbootimg)

### Structural / behavioural
- [x] No content change to `init-script`, `initramfs/`, `fixup-mountpoints`,
      `updater-script`, `updater-unpack.sh`
- [x] Legacy (header <= 2) path and lz4 option preserved
- [x] Original Jolla copyright headers preserved in the new scripts

## Results

Run standalone against the real repository files (no Android tree required):

- **init, boot & recovery:** `cmp` reported **IDENTICAL** against the original
  `sed … | fixup-mountpoints … | chmod +x` recipe output.
- **ramdisk:** `diff -r` of the extracted trees and a `find -printf '%y %m %p
  -> %l'` comparison reported **IDENTICAL** file lists, contents, modes, and
  symlinks; `/init` and `/bin/busybox` present.
- **compression:** gzip magic `1f 8b`; legacy LZ4 magic `02 21 4c 18`
  (`0x184C2102`) — the kernel-compatible legacy frame produced by `lz4 -l`.
- **mkbootimg:** a stub recorded argv; forwarding was exact and the
  space-containing `--cmdline` value remained one argument.

## Documented intentional deltas

1. **Empty-`fixup` guard** — `generate-init.sh` skips the fixup step when the
   fixup path is empty. The original recipe would try to execute the device name
   as a command (a latent bug). No difference when a `fixup-mountpoints` file
   exists, which is the normal case.
2. **Build-log text** printed during generation differs cosmetically.
3. **`--output` position** — placed at the end of the mkbootimg argument list;
   mkbootimg is flag-based, so output is unaffected.

## Remaining validation (requires full build / device)

Follow the canonical procedure in `VALIDATION.md`. For this change the device
resolves to the legacy or vendor_boot profile depending on the target; run the
checks for that profile. In summary:

- `mka hybris-boot` (and `mka hybris-recovery` only if the device has a
  dedicated recovery partition) in a real Android tree.
- Unpack the resulting images and confirm kernel, cmdline, offsets, header
  version and dt/dtb parity with a pre-refactor baseline build.
- On-device boot smoke test on the reference device (Pixel 5a / barbet):
  reaches the same point (debug shell / `switch_root`) as before.

## Reproduction

From the repository root (uses only the checked-in files plus a stub busybox /
mkbootimg):

```sh
tmp=$(mktemp -d); DP=/dev/mmcblk0p26; DEV=pdx235

# init equivalence (boot variant)
sed -e "s %DATA_PART% $DP g" -e "s %BOOTLOGO%  g" \
    -e "s %DEFAULT_OS% sailfishos g" -e "s %ALWAYSDEBUG%  g" \
    init-script > "$tmp/ref-init"
./fixup-mountpoints "$DEV" "$tmp/ref-init"; chmod +x "$tmp/ref-init"
scripts/generate-init.sh init-script "$tmp/new-init" "$DP" "" sailfishos "" \
    "$PWD/fixup-mountpoints" "$DEV"
cmp "$tmp/ref-init" "$tmp/new-init" && echo "init: IDENTICAL"

# ramdisk equivalence
printf 'FAKE-BUSYBOX\n' > "$tmp/busybox"
cp "$tmp/ref-init" "$tmp/i1"; cp "$tmp/ref-init" "$tmp/i2"
mkdir "$tmp/ref"; cp -a initramfs/* "$tmp/ref"; mv "$tmp/i1" "$tmp/ref/init"
cp "$tmp/busybox" "$tmp/ref/bin/"
( cd "$tmp/ref" && find . -printf '%P\n' | cpio -H newc -o ) | gzip -9 > "$tmp/ref.gz"
scripts/generate-ramdisk.sh initramfs "$tmp/i2" "$tmp/busybox" "$tmp/new.gz" "$tmp/work" gzip
mkdir "$tmp/rx" "$tmp/nx"
( cd "$tmp/rx" && gunzip -c "$tmp/ref.gz" | cpio -idm )
( cd "$tmp/nx" && gunzip -c "$tmp/new.gz" | cpio -idm )
diff -r "$tmp/rx" "$tmp/nx" && echo "ramdisk: IDENTICAL"

# mkbootimg argument forwarding
printf '#!/bin/sh\nfor a in "$@"; do echo "$a"; done\n' > "$tmp/mkb"; chmod +x "$tmp/mkb"
scripts/generate-bootimg.sh "$tmp/mkb" "$tmp/out.img" \
    --ramdisk "$tmp/new.gz" --cmdline "console=ttyMSM0 bootmode=debug"
```
