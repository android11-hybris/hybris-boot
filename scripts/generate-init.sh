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
# Generates the templated hybris init from init-script. This logic used to
# live inline in the Android.mk $(BOOT_RAMDISK_INIT) recipe; it is extracted
# here so it can be shared between build frontends (Android.mk today, and
# potentially Soong/Android.bp in future). Behaviour is equivalent to the
# original recipe (see docs/design/BOOT_GENERATION.md).
#
# Usage:
#   generate-init.sh SRC OUT DATA_PART BOOTLOGO DEFAULT_OS ALWAYSDEBUG \
#                    FIXUP_MOUNTS TARGET_DEVICE

set -e

SRC="$1"            # init-script template
OUT="$2"            # generated init output path
DATA_PART="$3"      # value for %DATA_PART%
BOOTLOGO="$4"       # value for %BOOTLOGO%
DEFAULT_OS="$5"     # value for %DEFAULT_OS%
ALWAYSDEBUG="$6"    # value for %ALWAYSDEBUG%
FIXUP_MOUNTS="$7"   # path to fixup-mountpoints (may be empty)
TARGET_DEVICE="$8"  # device codename passed to fixup-mountpoints

mkdir -p "$(dirname "$OUT")"

# Same sed expressions (space-delimited) as the original recipe.
sed -e "s %DATA_PART% ${DATA_PART} g" \
    -e "s %BOOTLOGO% ${BOOTLOGO} g" \
    -e "s %DEFAULT_OS% ${DEFAULT_OS} g" \
    -e "s %ALWAYSDEBUG% ${ALWAYSDEBUG} g" \
    "$SRC" > "$OUT"

# Rewrite by-name mount points to raw device nodes for this device.
# Guarded against an empty fixup path (which would otherwise try to run the
# device name as a command); a no-op when no fixup-mountpoints file exists.
if [ -n "$FIXUP_MOUNTS" ]; then
    "$FIXUP_MOUNTS" "$TARGET_DEVICE" "$OUT"
fi

chmod +x "$OUT"
