# ASUS ROG Flow Z13 (GZ302) minimum brightness fix for Linux

DKMS module that lowers the minimum screen brightness (backlight floor) on
the 2025 ASUS ROG Flow Z13 (GZ302) under Linux. Works on Arch, CachyOS and
other amdgpu systems.

The firmware reports a minimum backlight level of 539/65535, so 0%
brightness is still bright. This package rebuilds the kernel's
`drm_panel_backlight_quirks` module with an extra entry for the Z13 panel
(TMA 0x0803), so 0% gets much darker while the screen stays lit.

The entry was submitted upstream to dri-devel
(`drm: panel-backlight-quirks: Add ASUS ROG Flow Z13 (GZ302)`). Once your
kernel includes it, uninstall this package.

## Install (Arch / CachyOS)

```sh
yay -S z13-backlight-quirk-dkms   # or any AUR helper
reboot
```

You need the headers for your kernel (`linux-headers`,
`linux-cachyos-headers`, …). pacman's DKMS hook builds the module and
rebuilds your initramfs automatically, also on every kernel update.

Other distros: copy this directory to `/usr/src/z13-backlight-quirk-<version>`
(replace `@PKGVER@` in `dkms.conf` with that version), then
`dkms install z13-backlight-quirk/<version> -k $(uname -r)` and rebuild
your initramfs.

## Check

```sh
journalctl -k -b | grep "backlight quirk"   # Applying panel backlight quirk, min_brightness: 1
```

## Notes

- Only matches ASUS "ROG Flow Z13" with the TMA 0x0803 panel; otherwise
  the module behaves like the stock one.
- It ships a snapshot of the upstream quirk list, so quirks added later
  for *other* laptops are missing. Irrelevant on a Z13.
- If a kernel change breaks the build, DKMS fails and you boot the stock
  module (old floor). Nothing else breaks.
- For going darker still, Z13GUI+ has a software "Dim" (Settings > Display).

## Remove

```sh
sudo pacman -R z13-backlight-quirk-dkms
reboot
```

## Releasing

Push a `vX.Y.Z` tag. The Release workflow builds the package in an Arch
container, installs it next to stock `linux` headers and checks that DKMS
built the module, then creates the GitHub release and updates the AUR.
Run the same check locally with:

```sh
# after filling the placeholders in a copy of contrib/aur/PKGBUILD
docker run --rm -v "$PWD/contrib/aur:/pkg" archlinux:latest bash /pkg/check.sh
```

To republish an existing tag (bumps pkgrel), run the workflow manually with
that tag.

## License

GPL-2.0-only, like the kernel file it is based on.
