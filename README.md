# z13-backlight-quirk

Lowers the minimum screen brightness on the 2025 ASUS ROG Flow Z13 (GZ302).

The Z13's firmware tells the amdgpu driver its lowest allowed backlight
level, and that floor is fairly bright: at 0% brightness the panel still
reads 539 of 65535. Linux already has a list of laptops whose firmware
floor is too high (Framework 13, Steam Deck, …), kept in the
`drm_panel_backlight_quirks` kernel module. This package rebuilds that
module with one extra entry for the Z13 and its panel (TMA 0x0803), so
0% brightness gets noticeably darker while the screen stays lit.

The same entry was submitted upstream to dri-devel
(`drm: panel-backlight-quirks: Add ASUS ROG Flow Z13 (GZ302)`). Once a
kernel containing it is released, this package is no longer needed:
uninstall it.

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

- It only matches ASUS "ROG Flow Z13" laptops with the TMA 0x0803 panel.
  On anything else the module behaves exactly like the stock one.
- The module replaces the kernel's whole quirk list with a snapshot of
  the upstream list. Quirks that future kernels add for *other* laptops
  are missing while this package is installed; on a Z13 that does not
  matter.
- If a future kernel changes the module's internals, the DKMS build
  fails for that kernel and you simply boot with the stock module (the
  old floor). Nothing else breaks.
- The Z13GUI+ drawer also has a software "Dim" (Settings > Display) for
  going darker still, or for users without this package.

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
