# Open questions

> **Status:** Design
> **Last updated:** 2026-11-18
> **See also:** [README](README.md), all design docs

Undecided items and work that needs a decision before implementation. This is
the single place to look for "what haven't we decided yet?" Resolved items are
removed from this file and reflected in the owning design doc, with a commit
message that says which question was resolved.

## Product and installer

| Question | Options / notes | Owner doc |
| --- | --- | --- |
| Replace Calamares with Icicle? | Evaluate against encryption setup, flake-aware generation, aarch64, branding and maintenance. Keep Calamares until it clearly wins. | [`installer-and-first-boot.md`](installer-and-first-boot.md) |
| GUI settings frontend technology? | Qt/QML native vs web-based UI; must integrate with Plasma and survive without a browser. | [`user-experience.md`](user-experience.md) |
| Rename the live user from `nixos`? | Upstream profile hardcodes `/home/nixos` and auto-login; needs overrides. Cosmetic but visible. | [`installer-and-first-boot.md`](installer-and-first-boot.md) |
| Disko-style declarative partitioning in installer? | Nice for advanced users; risks complexity for everyday path. | [`installer-and-first-boot.md`](installer-and-first-boot.md) |

## Security and identity

| Question | Options / notes | Owner doc |
| --- | --- | --- |
| Secure Boot key management | lanzaboote + sbctl user keys; firmware support varies. Must keep graceful fallback. | [`security-defaults.md`](security-defaults.md) |
| TPM2 provisioning UX in installer | Automatic enrol with recovery key vs opt-in prompt. | [`installer-and-first-boot.md`](installer-and-first-boot.md) |
| Trusted-contacts recovery protocol details | Threshold parameters, approval UX, revocation, audit format. Default remains recovery codes. | [`duckpam.md`](duckpam.md) |
| Hardware token wrapping for DuckPAM | TPM2/FIDO2 wrapping of the encrypted key store; must not remove recovery path. | [`duckpam.md`](duckpam.md) |
| Root key rotation after compromise | Re-wrap group keys and shares; migration UX and detection. | [`duckpam.md`](duckpam.md), [`contacts.md`](contacts.md) |
| KEM library choice and audit | NTRU-HPS-2048-509 implementation, constant-time properties, upstream audit status. | [`duckpam.md`](duckpam.md) |
| Hosted Netmaker controller as optional convenience | Self-hosted remains default; if offered, must be clearly labelled and minimise metadata. | [`ducknet.md`](ducknet.md) |
| Mobile and roaming peers | Phone clients, key storage on mobile, roaming across networks. | [`ducknet.md`](ducknet.md) |
| IPv6 in DuckNet | Desirable but not required for first release. | [`ducknet.md`](ducknet.md) |

## Features and platform

| Question | Options / notes | Owner doc |
| --- | --- | --- |
| VM and Kubernetes deployment scope | Deferred by decision; revisit after Nix + containers are solid. | [`app-deployment.md`](app-deployment.md) |
| Output modules / stream handlers in the WM | Exploratory; needs its own design doc before work starts. | [`app-deployment.md`](app-deployment.md) |
| Cross-device Contacts sync protocol | End-to-end encrypted sync between a user's own devices. | [`contacts.md`](contacts.md) |
| Group recovery when all admins are lost | Emergency admin key vs trusted-contacts path. | [`contacts.md`](contacts.md) |
| vCard import / export | Interop with existing address books. | [`contacts.md`](contacts.md) |
| Default group storage server package | Ship a packaged server vs require users to host one. | [`file-sharing.md`](file-sharing.md) |
| Large-file and deduplication behaviour | Chunking, dedupe across groups, quota accounting. | [`file-sharing.md`](file-sharing.md) |

## Operations and polish

| Question | Options / notes | Owner doc |
| --- | --- | --- |
| CI for eval, ISO build, smoke tests, signing | No pipeline today; needed for the release checklist. | [`release-and-support.md`](release-and-support.md) |
| aarch64 build and test infrastructure | Native ARM builder vs emulated binfmt builds. | [`release-and-support.md`](release-and-support.md) |
| Published security contact and advisory process | Private reporting channel, acknowledgement and disclosure policy. | [`release-and-support.md`](release-and-support.md) |
| Replace placeholder URLs and finish branding artwork | `example.org` links, product banner/wallpaper, installer screenshots. | [`user-experience.md`](user-experience.md) |
| Custom GRUB theme and Plymouth logo | Currently uses NixOS defaults with Rix distro name. | [`user-experience.md`](user-experience.md) |
| Tvix re-evaluation trigger | Revisit when flake/fetcher support and a packaged build exist. See [`../docs/tvix.md`](../docs/tvix.md). | [`overview.md`](overview.md) |

## Decisions already made (do not re-litigate)

These are recorded here for clarity; they are documented in their owning docs:

- Rix tracks stable NixOS releases, not unstable by default.
- Flakes are enabled by default; installed systems get a generated `flake.nix`.
- Updates are automatic, atomic and reversible, applied at next boot by default.
- No telemetry or Rix-operated directory.
- DuckPAM's NTRU key is the root identity.
- Netmaker controller is user-/group-self-hosted by default.
- Recovery codes are the default; trusted contacts are opt-in.
- First-pass app deployment covers Nix modules and containers.
- Tvix is not on the installer critical path.
