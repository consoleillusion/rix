# Settings shared by the live ISO and by Rix systems after installation.
{ lib, ... }:
{
  # Distro identity. This feeds /etc/os-release, the GRUB menu entry and
  # anything else that asks NixOS what it is.
  system.nixos = {
    distroName = "Rix";
    distroId = "rix";
    vendorName = "Rix";
    vendorId = "rix";

    # Rix is a NixOS-based OS. Advertise that so tools which special-case
    # NixOS (installers, drivers, documentation) keep working.
    extraOSReleaseArgs.ID_LIKE = "nixos";
  };

  # Enable flakes and the unified CLI in the live environment and on
  # installed systems.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Unfree packages are opt-in. The installer offers a switch for this;
  # set it to `true` here if you want a more permissive default.
  nixpkgs.config.allowUnfree = lib.mkDefault false;
}
