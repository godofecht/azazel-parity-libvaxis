#!/bin/sh
# Stage libvaxis source at a pinned commit into vendor/libvaxis (git-ignored),
# so Azazel can build the vaxis library from source. Requires git. Re-running
# is safe.
set -eu
VAXIS_COMMIT=5ca495f09f413c66789d9c5061359b941a8d82c2
DIR=$(cd "$(dirname "$0")" && pwd)
VENDOR="$DIR/vendor/libvaxis"
if [ -f "$VENDOR/src/main.zig" ]; then
    echo "libvaxis source already staged at $VENDOR"; exit 0
fi
rm -rf "$VENDOR"; mkdir -p "$DIR/vendor"
echo "fetching libvaxis @ $VAXIS_COMMIT ..."
git clone --filter=blob:none https://github.com/rockorager/libvaxis "$VENDOR"
git -C "$VENDOR" checkout -q "$VAXIS_COMMIT"
echo "libvaxis source staged at $VENDOR"
