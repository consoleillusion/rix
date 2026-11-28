# Open questions

> **Status:** Design
> **Last updated:** 2026-11-18
> **See also:** [Design index](../index.md), all design docs

Undecided items and work that needs a decision before implementation. This is
the single place to look for "what haven't we decided yet?" Resolved items are
removed from this file and reflected in the owning design doc, with a commit
message that says which question was resolved.

## Product and installer

| Question | Options / notes |
| --- | --- |
| Replace Calamares with Icicle? | Evaluate against encryption setup, flake-aware generation, aarch64, branding and maintenance. Keep Calamares until it clearly wins. |
| GUI settings frontend technology? | Qt/QML native vs web-based UI; must integrate with Plasma and survive without a browser. |
| Rename the live user from `nixos`? | Upstream profile hardcodes `/home/nixos` and auto-login; needs overrides. Cosmetic but visible. |
| Disko-style declarative partitioning in installer? | Nice for advanced users; risks complexity for everyday path. |

## Security and identity

| Question | Options / notes |
| --- | --- |
| Secure Boot key management | lanzaboote + sbctl user keys; firmware support varies. Must keep graceful fallback. |
| TPM2 provisioning UX in installer | Automatic enrol with recovery key vs opt-in prompt. |
| Trusted-contacts recovery protocol details | Threshold parameters, approval UX, revocation, audit format. Default remains recovery codes. |
| Hardware token wrapping for DuckPAM | TPM2/FIDO2 wrapping of the encrypted key store; must not remove recovery path. |
| Root key rotation after compromise | Re-wrap group keys and shares; migration UX and detection. |
| KEM library choice and audit | NTRU-HPS-2048-509 implementation, constant-time properties, upstream audit status. |
| Hosted Netmaker controller as optional convenience | Self-hosted remains default; if offered, must be clearly labelled and minimise metadata. |
| Mobile and roaming peers | Phone clients, key storage on mobile, roaming across networks. |
| IPv6 in DuckNet | Desirable but not required for first release. |

## Features and platform

| Question | Options / notes |
| --- | --- |
| VM and Kubernetes deployment scope | Deferred by decision; revisit after Nix + containers are solid. |
| Output modules / stream handlers in the WM | Exploratory; needs its own design doc before work starts. |
| Cross-device Contacts sync protocol | End-to-end encrypted sync between a user's own devices. |
| Group recovery when all admins are lost | Emergency admin key vs trusted-contacts path. |
| vCard import / export | Interop with existing address books. |
| Default group storage server package | Ship a packaged server vs require users to host one. |
| Large-file and deduplication behaviour | Chunking, dedupe across groups, quota accounting. |
| Notification bridge packaging and trust | In-app is default; external Telegram/SMS/email bridges are user-configured and untrusted transports. |
| Standard event schema for group services | Needed before group apps can post status notifications consistently. |

## Operations and polish

| Question | Options / notes |
| --- | --- |
| CI for eval, ISO build, smoke tests, signing | No pipeline today; needed for the release checklist. |
| aarch64 build and test infrastructure | Native ARM builder vs emulated binfmt builds. |
| Published security contact and advisory process | Private reporting channel, acknowledgement and disclosure policy. |
| Replace placeholder URLs and finish branding artwork | `example.org` links, product banner/wallpaper, installer screenshots. |
| Custom GRUB theme and Plymouth logo | Currently uses NixOS defaults with SekkOS distro name. |
| Tvix re-evaluation trigger | Revisit when flake/fetcher support and a packaged build exist. See [`tvix`](../reference/tvix.md). |

## Decisions already made (do not re-litigate)

These are recorded here for clarity; they are documented in their owning docs:

- SekkOS tracks stable NixOS releases, not unstable by default.
- Flakes are enabled by default; installed systems get a generated `flake.nix`.
- Updates are automatic, atomic and reversible, applied at next boot by default.
- No telemetry or SekkOS-operated directory.
- DuckPAM's NTRU key is the root identity.
- Netmaker controller is user-/group-self-hosted by default.
- Recovery codes are the default; trusted contacts are opt-in.
- First-pass app deployment covers Nix modules and containers.
- Tvix is not on the installer critical path.
