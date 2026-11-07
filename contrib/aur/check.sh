#!/bin/bash
# DKMS needs the kernel's modules tree, so `linux` is installed with its headers.
# Runs inside archlinux:latest with the patched PKGBUILD mounted at /pkg.
# Builds the package, installs it next to stock (gcc-built) linux-headers, and
# fails unless pacman's DKMS hook built and installed the module.
set -euo pipefail
pacman -Syu --noconfirm --needed base-devel dkms linux linux-headers >/dev/null
useradd -m builder
chown -R builder /pkg
su builder -c 'cd /pkg && makepkg --printsrcinfo > .SRCINFO && makepkg --nodeps --noconfirm --cleanbuild'
pacman -U --noconfirm /pkg/*.pkg.tar.zst
dkms status
kver=$(ls /usr/lib/modules | head -1)
dkms status | grep -q "z13-backlight-quirk/.*, ${kver}, .*: installed"
ko=$(find "/usr/lib/modules/${kver}/updates/dkms" -name 'drm_panel_backlight_quirks.ko*')
modinfo -F vermagic "$ko"
# The Z13 entry must be in the built module.
case "$ko" in
*.zst) zstdcat "$ko" ;;
*.xz) xzcat "$ko" ;;
*) cat "$ko" ;;
esac | strings | grep -qx 'ROG Flow Z13'
echo "OK: built and installed for ${kver}"
