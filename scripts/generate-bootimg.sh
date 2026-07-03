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
# Thin wrapper around mkbootimg. Argument computation stays in the build
# frontend; this script only applies the arguments and writes the output
# image. Extracted from the Android.mk image recipes so it can be shared
# between build frontends (see docs/design/BOOT_GENERATION.md).
#
# Usage:
#   generate-bootimg.sh MKBOOTIMG OUTPUT [mkbootimg args...]

set -e

MKBOOTIMG="$1"      # path to the mkbootimg tool
OUTPUT="$2"         # output image path
shift 2

echo "Making $OUTPUT"

mkdir -p "$(dirname "$OUTPUT")"
rm -rf "$OUTPUT"

exec "$MKBOOTIMG" "$@" --output "$OUTPUT"
