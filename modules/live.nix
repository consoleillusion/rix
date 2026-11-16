# Live-ISO-specific settings on top of the upstream NixOS installer image.
{ config, lib, pkgs, ... }:
let
  cpu = pkgs.stdenv.hostPlatform.parsed.cpu.name;
in
{
  # Distinguish the ISO from an installed Rix system in /etc/os-release.
  system.nixos.variantName = "Live Installer";
  system.nixos.variant_id = "live";

  networking.hostName = "rix-live";

  # The live medium never boots from a ZFS root pool, so it does not need the
  # pool-import bypass. This also matches the recommended default from 26.11
  # on (26.05 still defaults to `true` and warns about it).
  boot.zfs.forceImportRoot = false;

  # ISO naming. `volumeID` is the filesystem label stage-1 mounts the ISO
  # from, and must stay within 32 characters. The base name is normally set
  # unconditionally by the upstream ISO module, so force our value.
  image.baseName = lib.mkForce "rix-live-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}";
  isoImage.volumeID = "RIX_LIVE_${config.system.nixos.release}_${cpu}";
  isoImage.appendToMenuLabel = " (Live)";

  # Branding for the console lives, in case the graphical session is not
  # used. The `nixos` user comes from NixOS's installation-device profile.
  users.motd = ''
    Welcome to Rix — a NixOS-based operating system.

    The installer starts automatically in the graphical session. If it does
    not, run `calamares` from a terminal.

    The live user is "nixos" with an empty password; use `sudo` for root.
    Manual installs can follow the NixOS manual:
      https://nixos.org/manual/nixos/stable/
  '';

  services.getty.helpLine = lib.mkForce ''
    Rix live environment — the "nixos" user is logged in automatically.

    If the graphical installer did not start, run `calamares`.
    To install manually, use `sudo -i` and follow the NixOS manual.
  '';
}
