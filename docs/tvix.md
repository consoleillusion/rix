# Tvix status and why Rix does not use it (yet)

Tvix is TVL's Rust implementation of the Nix language and package manager. It
is an interesting long-term foundation for a Nix-based OS, but it cannot drive
a NixOS/Calamares installer today. This document records the findings behind
that decision and what would have to change.

Checked against upstream in November 2026:

- Project: <https://tvix.dev/>, source mirror
  <https://github.com/tvlfyi/tvix> (developed in the TVL `depot` monorepo).
- Upstream README: *"Tvix is not ready for use in production. None of our
  current APIs should be considered stable in any way."*
- The CLI is a preliminary evaluator/REPL (`tvix/cli`), not a Nix-compatible
  `nix build`/`nix profile` front end.
- Flake support is absent from the CLI. Fetch-related builtins are still
  marked TODO upstream: `fetchGit` and `fetchTree` are unfinished, and flakes
  depend on tree fetching and lockfile resolution.
- The project does provide interesting pieces: `tvix-eval`, `tvix-store`
  (content-addressed store), `tvix-build`, `tvix-glue`, and a Nix-daemon
  compatible daemon backed by Tvix.
- Tvix is not packaged in nixpkgs `nixos-26.05` or `master` (no `pkgs.tvix`),
  and the published mirror has no flake output to consume. Building it today
  means building the Rust workspace from source.

## Why it is not in the installer critical path

Calamares' NixOS module is not just an evaluator client. It runs:

- `nixos-generate-config --root ...` to produce `hardware-configuration.nix`,
- `nixos-install --root ...`, which assumes channels, Nix profiles, a store
  database, `<nixpkgs>` in `NIX_PATH`, and NixOS activation scripts,
- package builds through the host Nix daemon/store.

Rix additionally asks for flakes, which Tvix does not implement. Replacing Nix
here would mean writing a store/profile/activation layer plus a new installer
backend before the first ISO could boot — with unstable upstream APIs and no
packaged binary to test against. That is a research project, not a safe
default for an installer.

## What would make it viable

1. Flake and fetcher support in `tvix` (including lockfile resolution).
2. A stable build/profile CLI, or a Nix-compatible daemon with roots and
   profiles sufficient for `nixos-rebuild`/`switch-to-configuration`.
3. A packaged `tvix`/`tvix-store` in nixpkgs, or a pinned flake output.
4. A Calamares backend (or replacement installer) that targets that store and
   can install a NixOS system without C++ Nix.

Until then, the pragmatic split is:

- Keep Nix as the store and installer engine (this scaffold).
- Evaluate with Tvix in CI where pure evaluation is enough, once available.
- Keep the installer customisation isolated in `modules/calamares.nix` so a
  Tvix-backed backend can be added without restructuring the ISO.

## Trying Tvix safely

Build it outside the ISO from the TVL workspace so it never affects installs:

```console
$ git clone https://code.tvl.fyi/depot.git:workspace=views/tvix.git
$ cd tvix
$ nix-shell
$ cargo build
$ ./target/debug/tvix --help
```

Do not add it to the live image or to `configuration.nix` until there is a
pinned, packaged release and the gaps above are closed.
