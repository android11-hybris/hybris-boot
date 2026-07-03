# AI Development Guide

This repository welcomes AI-assisted development.

The goal of this document is to help AI assistants produce changes consistent with the project's design philosophy.

---

# Project Philosophy

This repository modernizes the original Mer/Jolla hybris-boot project.

It is **not** a rewrite.

Prefer extending existing code over replacing it.

---

# Coding Rules

Never remove copyright notices.

Preserve project history.

Follow the surrounding coding style.

Avoid unnecessary formatting changes.

Keep commits focused.

Document behavioral changes.

---

# Preferred Workflow

1. Understand existing implementation.
2. Make minimal changes.
3. Explain reasoning.
4. Preserve compatibility.
5. Update documentation when behavior changes.

---

# Architecture

The project targets Android 11+.

Support:

- vendor_boot
- boot header v3/v4
- GKI
- first-stage init
- logical partitions
- dynamic partitions

Avoid introducing distribution-specific behavior.

---

# Development Device

Google Pixel 5a (barbet)

Android Base:

LineageOS 19.1

Kernel:

Linux 4.19

Halium:

12

---

# Preferred Commit Style

docs:
build:
boot:
vendor_boot:
dynamic-partitions:
debug:
pixel5a:
