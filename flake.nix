{
  description = "SekkOS — a NixOS-based operating system with a Calamares live installer";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      configurationName = system: "sekkos-live-${system}";

      mkLiveIso =
        system:
        lib.nixosSystem {
          inherit system;
          modules = [
            ./profiles/live.nix
            ./modules/common.nix
            ./modules/live.nix
            ./modules/calamares.nix
          ];
        };

      liveConfigurations = lib.genAttrs systems mkLiveIso;
    in
    {
      nixosConfigurations = lib.listToAttrs (
        map (system: lib.nameValuePair (configurationName system) liveConfigurations.${system}) systems
      );

      packages = lib.genAttrs systems (
        system:
        let
          iso = self.nixosConfigurations.${configurationName system}.config.system.build.isoImage;
        in
        {
          default = iso;
          inherit iso;
        }
      );

      formatter = lib.genAttrs systems (system: nixpkgs.legacyPackages.${system}.nixfmt);
    };
}
