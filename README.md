# hybris-boot

This project enables the building of boot images for Google Android fastboot based devices.

It can be built either in the Android build tree as part of the normal kernel/Android build or in a Mer SDK as a standalone package.

---

# Android Build

Extend `subdir_makefiles` in `build/core/main.mk` to include `hybris/Android.mk`, which then includes any additional `Android.mk` files in subdirectories.

The default `boot.img` is created by `$(INSTALLED_BOOTIMAGE_TARGET)` in `build/core/Makefile` and serves as the reference implementation.

Build as normal:

```bash
mka hybris-boot hybris-recovery
```

---

# SDK Building

The SDK requires the kernel, kernel modules, and a static BusyBox package.

```bash
git clone https://github.com/mer-hybris/hybris-boot
cd hybris-boot
make <device>
```

---

# Operating System Bootstrap

The initramfs boots into a Mer-derived operating system by mounting the default Android `/data` partition and bind mounting a Linux root filesystem located under:

```
/data/media/0/.stowaways/<os>
```

This behavior can be customized by modifying the generated init script.

---

# Initial RAMFS Debug Console

Boot the image in debug mode:

```bash
sudo fastboot boot boot.img -c bootmode=debug
```

Wait for USB networking to initialize, then connect:

```bash
telnet 192.168.2.15
```

---

# Android 11+ Modernization

This repository is the home of an ongoing modernization effort for **hybris-boot** targeting Android 11 and newer devices.

The objective is to preserve the original Mer/Jolla architecture while extending it to support modern Android platform features including:

- Android 11+
- Android 12
- Android 13+
- Android 14+
- Boot Header v3/v4
- `vendor_boot`
- Dynamic Partitions
- Logical Partitions
- Android First-Stage Init
- Generic Kernel Image (GKI)

The project is intended to remain distribution-neutral and support operating systems such as:

- Sailfish OS
- Droidian
- Ubuntu Touch
- LuneOS
- Other libhybris-based Linux systems

---

# Project Philosophy

This project is **not** a rewrite of hybris-boot.

Instead, it is a continuation of the original Mer/Jolla work, extending the existing architecture to support modern Android devices while preserving compatibility with legacy devices whenever practical.

Whenever possible:

- Preserve the original architecture.
- Preserve existing functionality.
- Preserve project history.
- Preserve original copyright notices.
- Minimize unnecessary rewrites.
- Prefer extending existing code over replacing it.

---

# Documentation

General project documentation:

- `docs/PROJECT.md`
- `docs/ROADMAP.md`
- `docs/CONTRIBUTING.md`
- `docs/AI-CONTEXT.md`
- `docs/AGENTS.md`

Engineering documentation:

- `docs/design/ARCHITECTURE.md`
- `docs/design/ANDROID11_BOOTFLOW.md`
- `docs/design/VENDOR_BOOT.md`
- `docs/design/BOOT_IMAGE_SELECTION.md`
- `docs/design/FIRST_STAGE_INIT.md`
- `docs/design/DYNAMIC_PARTITIONS.md`
- `docs/design/PIXEL5A.md`
- `docs/design/RESEARCH.md`

---

# AI-Assisted Development

AI-assisted development is welcome.

Project context and development guidance are provided to help AI coding assistants understand the project's goals, architecture, coding standards, and current technical direction.

These documents are intended to improve collaboration between human contributors and AI assistants while preserving the original design philosophy of hybris-boot.

---

# Current Status

The modernization effort is currently focused on Android 11+ compatibility.

Current areas of development include:

- Android 11/12 build integration
- Boot Header v3/v4 support
- `vendor_boot` modernization
- Android first-stage init compatibility
- Dynamic partition support
- Improved debugging infrastructure
- Google Pixel 5a (barbet) reference implementation

---

# Credits

This repository is based on the original **hybris-boot** project developed by the Mer Project and Jolla contributors.

The Android 11+ modernization effort is intended as a continuation of that work.

All original copyright notices, authorship, and project history are preserved.
