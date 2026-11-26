# Composition of the SekkOS live ISO.
{ modulesPath, ... }:
{
  imports = [
    # Upstream NixOS image providing the graphical Calamares installer,
    # a Plasma 6 live session, hardware scanning, networking, auto-login
    # and the passwordless `nixos` live user.
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
  ];
}
