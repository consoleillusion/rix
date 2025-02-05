# Release and support

> **Status:** Mixed
> **Last updated:** 2026-11-18
> **See also:** [Stability and updates](05-stability-and-updates.md), [Overview](00-overview.md), [../flake.nix](../flake.nix)

This document defines how Rix versions, builds, tests, publishes and supports
releases. It matches the current flake, which tracks `nixos-26.05`.

## Versioning

- Rix versions mirror the NixOS release they are based on: **Rix 26.05** tracks
  `nixpkgs/nixos-26.05`.
- ISO names follow `rix-live-<version>.<date>.<rev>-<system>.iso`, derived from
  `config.system.nixos.label` in [`../modules/live.nix`](../modules/live.nix).
- Volume labels stay short and stable, e.g. `RIX_LIVE_26.05_x86_64`, because
  stage-1 uses them to find the medium.
- Development builds may carry a `pre` suffix; the Calamares overlay maps that
  to the `nixos-unstable` branch in the generated flake
  ([`../modules/calamares.nix`](../modules/calamares.nix)).

## Channels

| Channel | Purpose | Default? |
| --- | --- | --- |
| `stable` | Tested builds of the current Rix release. | Yes |
| `testing` | Candidates for the next release; opt-in. | No |
| `unstable` | Development snapshots; not for everyday machines. | No |

Users switch channels in Rix Settings or by changing the flake input; the
change is an atomic rebuild and is reversible.

## Support window

- A Rix release is supported until the next Rix release plus three months.
- Security fixes are backported to supported releases.
- End-of-life is announced at least two months in advance, with a documented
  upgrade path.
- Only supported releases receive tested update builds.

## Branches and code policy

- `main` is releasable; feature work happens in short-lived branches.
- Every change to a default, flow or data model updates the relevant design
  doc in the same commit ([`README.md`](README.md) maintenance rules).
- Conventional commit prefixes keep history readable, e.g.
  `docs(design): ...`, `feat(installer): ...`, `fix(calamares): ...`.

## Release checklist

1. **Update the pin.** `nix flake update nixpkgs` or move to the next stable
   NixOS branch.
2. **Repair the patch if needed.** Run `patch --dry-run` against the pinned
   `calamares-nixos-extensions/src/modules/nixos/main.py`. If it fails,
   regenerate against the new upstream file following
   [`../README.md`](../README.md).
3. **Update version strings** in
   [`../calamares/branding/rix/branding.desc`](../calamares/branding/rix/branding.desc).
4. **Evaluate all systems** for x86_64 and aarch64.
5. **Build both ISOs** in CI or on a configured builder.
6. **Smoke test** boot (BIOS and UEFI), Plasma session, Calamares start,
   encryption unlock and first boot.
7. **Verify defaults** from
   [`04-security-defaults.md`](04-security-defaults.md).
8. **Publish** ISOs with checksums; sign artifacts once signing is in place.
9. **Announce** changes, known issues and the support window.

Automated steps belong in CI; today they are manual — see
[`15-open-questions.md`](15-open-questions.md).

## Artifact integrity

- Publish SHA-256 checksums for every ISO.
- Sign release artifacts and checksums (planned).
- Publish build inputs via `flake.lock` so a build can be reproduced.
- A reproducible-build check compares independent builds byte-for-byte where
  feasible.

## Security response

1. Users and researchers can report issues privately through a documented
   security contact (to be published; tracked in
   [`15-open-questions.md`](15-open-questions.md)).
2. Acknowledge within a short window, triage by severity, and keep the reporter
   informed.
3. Fix in the affected supported releases, test, and publish an advisory with
   affected versions and mitigation.
4. Critical system issues ship through the automatic update path; see
   [`05-stability-and-updates.md`](05-stability-and-updates.md).

## Current gaps

- No CI pipeline for evaluation, ISO build or signing.
- No published security contact or advisory process yet.
- aarch64 builds need a native ARM builder or configured emulation.
- URLs in branding are still placeholders.
- The initial install is channel-based; the generated flake takes over at the
  first rebuild.

These are tracked in [`15-open-questions.md`](15-open-questions.md) and in the
"Known limitations" section of [`../README.md`](../README.md).
