# SekkOS overview

> **Status:** Mixed
> **Last updated:** 2026-11-18
> **See also:** [Principles](principles.md), [Architecture](../system-design/architecture.md), [User experience](../experience/user-experience.md)

## What SekkOS is

SekkOS is a NixOS-based operating system aimed at everyday users: friends and
family, privacy-aware individuals, and small groups. Its defining idea is that
**relationships between people and groups drive access to resources** —
networks, files, applications and notifications.

Concretely, the repository today builds a **live installer ISO** that:

- boots a Plasma 6 desktop and auto-starts a branded Calamares installer;
- uses NixOS's upstream `installation-cd-graphical-calamares-plasma6` profile
  for the live session;
- writes an installed system that carries the SekkOS identity (`ID=sekkos`,
  `ID_LIKE=nixos`) and a `flake.nix`, so it is flake-managed from the first
  rebuild onward;
- targets `x86_64-linux` and `aarch64-linux`.

The larger product adds a GUI configuration layer, secure defaults, and the
Contacts, DuckPAM, DuckNet and file-sharing features described in this design
set. Those are **planned**, not shipped.

## Why build on NixOS

NixOS is the foundation because it gives us properties that are expensive to
build from scratch and directly serve usable security and stability:

| Property | What it gives SekkOS |
| --- | --- |
| **Declarative configuration** | The whole system is described in modules. A GUI can generate that configuration, diff it, and apply it atomically — no imperative "setup scripts" that drift. |
| **Atomic upgrades and rollback** | Each rebuild produces a new system generation with its own boot entry. A bad update is reversible from the boot menu or the GUI. |
| **Immutable `/nix/store`** | Store paths are read-only and content-addressed. Malware cannot silently replace system binaries; garbage collection is safe and predictable. |
| **Pinning and reproducibility** | `flake.lock` pins exact inputs (see [`flake.lock`](../../flake.lock)). A known-good system can be reproduced, which is essential for testing and incident response. |
| **Generations and GC** | Old generations remain bootable; disk reclamation is explicit. Recovery is a first-class operation rather than a reinstall. |
| **Large package set and modules** | Thousands of packaged applications and systemd services with sane unit-level sandboxing, across x86_64 and aarch64. |
| **Security options** | Full-disk encryption, a stateful firewall (enabled by default in the pinned nixpkgs), service hardening, `security.*` options and unprivileged service users are expressible in configuration. |
| **Flakes** | A single, versioned entry point for a system (`/etc/nixos/flake.nix`) with locked dependencies — enabled by default in SekkOS via [`modules/common.nix`](../../modules/common.nix). |

## What NixOS does *not* give us

NixOS is an excellent substrate, not a finished desktop product. SekkOS must add:

- **Curation and safe defaults.** NixOS is permissive by design; SekkOS chooses
  secure, usable defaults and documents the escape hatches
  ([`security-defaults`](../system-design/security-defaults.md)).
- **A GUI configuration frontend.** Users should never need to write Nix to
  change a setting, install an app or manage a group
  ([`user-experience`](../experience/user-experience.md)).
- **A smooth, Windows-familiar experience.** Plasma 6, predictable settings,
  human-readable errors, no surprise terminals — explicitly not the "rough
  edges" of a minimal Arch or bare NixOS install.
- **Identity and relationship services.** DuckPAM, Contacts, DuckNet, Iroh
  file sharing and app deployment are SekkOS components, not NixOS features.
- **Release and support policy.** A stable channel, tested updates and a
  defined support window ([`release-and-support`](../operations/release-and-support.md)).

## Product shape

```
Build time     flake.nix ──> nixosConfigurations ──> live ISO (+ aarch64)
                                   │
Live session   Calamares + SekkOS branding ──> installs ──> configuration.nix + flake.nix
                                                          │
Installed SekkOS  NixOS generations ──> GUI Settings ──> user intent ──> Nix modules
               │
               ├── DuckPAM: login unlocks post-quantum identity and secrets
               ├── Contacts: people and groups as the access-control unit
               ├── DuckNet: Netmaker/WireGuard mesh per group
               ├── File manager: Iroh P2P sharing with pinning
               └── Software centre: Nix modules and containers
```

## Goals

1. Secure by default for non-experts, without blocking legitimate use.
2. Stable and boring in daily operation; updates are atomic and reversible.
3. Usable without Nix knowledge, while keeping Nix fully available underneath.
4. User-controlled infrastructure — no SekkOS-operated surveillance or mandatory
   cloud service.
5. Local-first and offline-capable, with optional sync and sharing.
6. Familiar enough to replace Windows for everyday tasks.

## Non-goals

- Being a general-purpose server platform or a Kubernetes distribution first.
- Absolute immunity to compromise. We design against the threats in
  [`threat-model`](../system-design/threat-model.md); we do not claim perfection.
- Replacing NixOS's package model or forking the Nix language.
- Shipping a Tvix-based installer at this stage; see
  [`tvix`](../reference/tvix.md).

## Current implementation snapshot

| Area | Today | Source |
| --- | --- | --- |
| Flake and ISO outputs | Implemented | [`../../flake.nix`](../../flake.nix) |
| Live profile | Implemented | [`../../profiles/live.nix`](../../profiles/live.nix) |
| Distro identity, flakes, unfree policy | Implemented | [`../../modules/common.nix`](../../modules/common.nix) |
| Live hostname, ISO label, MOTD | Implemented | [`../../modules/live.nix`](../../modules/live.nix) |
| Calamares branding and chooser | Implemented | [`../../modules/calamares.nix`](../../modules/calamares.nix) |
| Installed-system branding and flake | Implemented via patch | [`../../calamares/patches/installed-config-branding.patch`](../../calamares/patches/installed-config-branding.patch) |
| GUI settings, Contacts, DuckPAM, DuckNet, Iroh | Designed here | [`principles`](principles.md) onward |
