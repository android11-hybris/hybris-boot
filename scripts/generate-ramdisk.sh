#!/bin/sh
#
# Copyright (C) 2014 Jolla Oy
# Contact: <david.greaves@jolla.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Frontend-independent boot generation helper.
#
# Assembles the hybris initramfs cpio archive. This logic used to live inline
# in the Android.mk $(BOOT_RAMDISK)/$(RECOVERY_RAMDISK) recipes; it is
# extracted here so it can be shared between build frontends. Behaviour is
# equivalent to the original recipe (see docs/design/BOOT_GENERATION.md).
#
# Usage:
#   generate-ramdisk.sh SRC_DIR INIT BUSYBOX OUT WORKDIR COMPRESS [LZ4]
#     COMPRESS : "gzip" (default) or "lz4"
#     LZ4      : path to the lz4 tool (used only when COMPRESS=lz4)

set -e

SRC_DIR="$1"        # initramfs skeleton directory
INIT="$2"           # generated init (moved into the staging dir)
BUSYBOX="$3"        # static busybox binary
OUT="$4"            # output ramdisk archive
WORKDIR="$5"        # staging directory
COMPRESS="$6"       # gzip | lz4
LZ4="${7:-lz4}"     # lz4 tool path

echo "Making initramfs : $OUT"

rm -rf "$WORKDIR"
mkdir -p "$WORKDIR"
cp -a "$SRC_DIR"/* "$WORKDIR"

# Deliberately mv (not cp) init to force the frontend to rebuild it every
# time: init depends on build variables that are hard to express as file
# dependencies.
mv "$INIT" "$WORKDIR/init"

cp "$BUSYBOX" "$WORKDIR/bin/"

if [ "$COMPRESS" = "lz4" ]; then
    ( cd "$WORKDIR" && find . -printf '%P\n' | cpio -H newc -o ) | "$LZ4" -l -12 --favor-decSpeed > "$OUT"
else
    ( cd "$WORKDIR" && find . -printf '%P\n' | cpio -H newc -o ) | gzip -9 > "$OUT"
fi
