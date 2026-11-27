<p align="center">
<img src="./sekkos.svg" width="200" alt="sekkos logo"/>
</p>

# SekkOS

SekkOS is a NixOS-based operating system. This repository builds its **live
installer**: a bootable ISO with a KDE Plasma 6 live session and the
[Calamares](https://calamares.io/) graphical installer, preconfigured to
install a Plasma 6 SekkOS system.

The scaffold targets `x86_64-linux` and `aarch64-linux`.

## What you get

- A graphical live ISO that boots straight into Plasma 6 and auto-starts the
  installer.
- SekkOS branding for Calamares (logo, wordmark, colours, slideshow, welcome
  text) and for the live system's `/etc/os-release` and GRUB entry.
- A Plasma-first desktop chooser (Plasma 6 or a minimal console system).
- A small patch so the `configuration.nix` written by the installer carries
  the SekkOS identity into the installed system (`ID=sekkos`, `ID_LIKE=nixos`) and
  ships a `flake.nix`, so the installed system is managed with flakes from the
  first rebuild onward.
- Flake outputs for both architectures, plus ISO filename/label branding.

## Repository layout

| Path | Purpose |
| --- | --- |
| `flake.nix` | Pins nixpkgs, builds `nixosConfigurations.sekkos-live-*` and ISO packages. |
| `profiles/live.nix` | Pulls in NixOS's upstream `installation-cd-graphical-calamares-plasma6` image. |
| `modules/common.nix` | Distro identity (`/etc/os-release`), flakes, unfree policy. Shared with installed systems. |
| `modules/live.nix` | ISO name/label, console branding, live hostname and MOTD. |
| `modules/calamares.nix` | Overrides `calamares-nixos-extensions`: branding, desktop chooser, install-time patch. |
| `calamares/branding/sekkos/` | `branding.desc`, `show.qml`, SVGs used by the installer UI. |
| `calamares/patches/` | Patch applied to Calamares' generated `configuration.nix` and `flake.nix`. |
| `docs/tvix.md` | Why Tvix is not used yet, and what it would take. |

## Build the ISO

You need Nix with flakes enabled, a Linux builder for the target
architecture, about 25 GiB of free disk space and at least 8 GiB of RAM for
the x86_64 image (the Plasma/Calamares closure is large).

```console
$ nix build .#iso
$ ls -lh result/iso/
```

`.#iso` resolves to `packages.<your-system>.iso`. Equivalent explicit forms:

```console
$ nix build .#packages.x86_64-linux.iso
$ nix build .#packages.aarch64-linux.iso
$ nix build                # packages.<system>.default, same as .#iso
```

The ISO filename looks like
`sekkos-live-26.05.<date>.<rev>-x86_64-linux.iso`, and its label is
`SEKKOS_LIVE_26.05_x86_64` (used by stage-1 to find the medium).

### Building for aarch64

An `aarch64-linux` ISO must be built by an ARM machine or a configured
remote builder. To use emulation on an x86_64 build host, enable binfmt in
that host's NixOS configuration:

```nix
boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
```

Emulated builds of a full Plasma ISO are slow; a native ARM builder or a
remote `nix.buildMachines` entry is strongly recommended.

## Try it in a VM

```console
$ nix run nixpkgs#qemu -- \
    -enable-kvm -m 4096 -smp 4 \
    -drive file=result/iso/sekkos-live-*.iso,media=cdrom,readonly=on \
    -boot d
```

For UEFI testing, add an OVMF firmware (`-bios /path/to/OVMF.fd`) or boot
the ISO with `virt-manager`/`libvirt`. On macOS use UTM with an ARM VM and
the aarch64 ISO.

## Write it to USB

```console
$ lsblk                      # identify the target device, e.g. /dev/sdX
$ sudo dd if=result/iso/sekkos-live-*.iso of=/dev/sdX \
    bs=4M status=progress oflag=sync
```

This is destructive: double-check the device. The ISO is bootable on BIOS
and UEFI systems.

## How the pieces fit together

1. `profiles/live.nix` imports NixOS's stock
   `installation-cd-graphical-calamares-plasma6.nix`. That upstream image
   provides the live user (`nixos`), auto-login, networking, hardware
   scanning, Plasma 6 and `calamares-nixos` (Calamares + NixOS modules).
2. `modules/calamares.nix` adds an overlay that overrides the
   `calamares-nixos-extensions` package:
   - the `sekkos` branding directory is installed into
     `share/calamares/branding/sekkos`;
   - `settings.conf` is switched from `branding: nixos` to `branding: sekkos`;
   - `packagechooser.conf` is replaced with a Plasma-first chooser;
   - `lib/calamares/modules/nixos/main.py` receives a patch that adds the
     SekkOS block to the generated `configuration.nix` and writes a matching
     `flake.nix` for the installed system.
3. `nixos-install` runs from the live medium using the same pinned nixpkgs
   that built the ISO, then the installer finishes with the usual Calamares
   steps.

The initial install is still channel-based (that is what `nixos-install`
does), but `/etc/nixos/flake.nix` is written during installation, so all
subsequent rebuilds are flake-based:

```console
$ sudo nixos-rebuild switch --flake /etc/nixos#$(hostname)
$ sudo nix flake update --flake /etc/nixos   # move the nixpkgs pin
```

The first rebuild creates `flake.lock`; commit it if you keep `/etc/nixos` in
git.

## Customise

### Name and identity

- `modules/common.nix` — `system.nixos.distroName`, `distroId`, vendor
  fields and `ID_LIKE`.
- `modules/live.nix` — hostname, ISO base name, volume label, console text.
- `calamares/branding/sekkos/branding.desc` — installer strings (product name,
  version, URLs) and colours.

### Installer artwork

Drop replacements into `calamares/branding/sekkos/`. PNG, JPEG and SVG all work.
`productLogo` should be square; `productWelcome` is shown on the welcome page.
Set `productWallpaper`/`productBanner` in `branding.desc` when you have them.
`show.qml` is the installation progress slideshow (Calamares slideshow API 2).

### Desktop selection

Edit the `packageChooser` definition in `modules/calamares.nix`. Keep the ids
`plasma6` and `""` in sync with the upstream `main.py`, which maps them to
desktop configuration. Adding GNOME or Xfce entries also works, but check
that upstream still supports those ids.

### Version

`flake.nix` pins `nixos-26.05`. Update with:

```console
$ nix flake update nixpkgs
```

Then update the version strings in `calamares/branding/sekkos/branding.desc`
and rebuild.

### Installed-system configuration

`calamares/patches/installed-config-branding.patch` is applied to the
`nixos` Calamares module from the pinned nixpkgs. It is intentionally small
and reviewable: it brands the generated `configuration.nix` and writes a
`flake.nix` next to it. If a nixpkgs update changes `main.py`, the build fails
loudly at the `patch` step. Regenerate it against the new upstream file:

```console
$ nixpkgs=$(nix eval --raw .#nixosConfigurations.sekkos-live-x86_64-linux.pkgs.path)
$ cp "$nixpkgs/pkgs/by-name/ca/calamares-nixos-extensions/src/modules/nixos/main.py" /tmp/main.py
# edit /tmp/main.py, then diff -u --label a/main.py --label b/main.py ...
```

If you do not want to brand the installed system, delete the `patch` line in
`modules/calamares.nix` and the `calamares/patches/` directory.

## Known limitations / next steps

- The live user is still `nixos`. Upstream's Plasma ISO module hardcodes
  `/home/nixos` and the auto-login user, so renaming it requires additional
  overrides.
- Installer URLs in `branding.desc` are placeholders (`example.org`).
- The fresh install is built from the live medium's Nixpkgs channel; the
  generated flake takes over from the first `nixos-rebuild`.
- Tvix is deliberately not wired in: it is not production-ready, lacks flake
  and fetcher support, and is not packaged in nixpkgs. See
  [docs/tvix.md](docs/tvix.md) for the full assessment and the path to a
  Tvix-backed installer.
- No custom GRUB theme or Plymouth logo yet. NixOS's boot menu already uses
  `system.nixos.distroName`; a branded theme can be added with
  `isoImage.grubTheme` and `boot.plymouth.logo`.
- Secure Boot signing is not set up. Add `lanzaboote` or sign the ISO
  artifacts in CI if you need it.
- The generated `flake.nix` pins `nixos-<release>`; the initial install itself
  is still performed by `nixos-install` from the live medium's store.
- Disko-style declarative partitioning is not part of the installer yet.
- Build and publish the ISO in CI, with a checksum and, ideally, a
  reproducible-build check.

## License

MIT. See [LICENSE](LICENSE).
