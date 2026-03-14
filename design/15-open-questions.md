# Open questions

> **Status:** Design
> **Last updated:** 2026-11-18
> **See also:** [README](README.md), all design docs

Undecided items and work that needs a decision before implementation. This is
the single place to look for "what haven't we decided yet?" Resolved items are
removed from this file and reflected in the owning design doc, with a commit
message that says which question was resolved.

## Product and installer

| # | Question | Options / notes | Owner doc |
| --- | --- | --- | --- |
| Q1 | Replace Calamares with Icicle? | Evaluate against encryption setup, flake-aware generation, aarch64, branding and maintenance. Keep Calamares until it clearly wins. | [`07-installer-and-first-boot.md`](07-installer-and-first-boot.md) |
| Q2 | GUI settings frontend technology? | Qt/QML native vs web-based UI; must integrate with Plasma and survive without a browser. | [`06-user-experience.md`](06-user-experience.md) |
| Q3 | Rename the live user from `nixos`? | Upstream profile hardcodes `/home/nixos` and auto-login; needs overrides. Cosmetic but visible. | [`07-installer-and-first-boot.md`](07-installer-and-first-boot.md) |
| Q4 | Disko-style declarative partitioning in installer? | Nice for advanced users; risks complexity for everyday path. | [`07-installer-and-first-boot.md`](07-installer-and-first-boot.md) |

## Security and identity

| # | Question | Options / notes | Owner doc |
| --- | --- | --- | --- |
| Q5 | Secure Boot key management | lanzaboote + sbctl user keys; firmware support varies. Must keep graceful fallback. | [`04-security-defaults.md`](04-security-defaults.md) |
| Q6 | TPM2 provisioning UX in installer | Automatic enrol with recovery key vs opt-in prompt. | [`07-installer-and-first-boot.md`](07-installer-and-first-boot.md) |
| Q7 | Trusted-contacts recovery protocol details | Threshold parameters, approval UX, revocation, audit format. Default remains recovery codes. | [`08-duckpam.md`](08-duckpam.md) |
| Q8 | Hardware token wrapping for DuckPAM | TPM2/FIDO2 wrapping of the encrypted key store; must not remove recovery path. | [`08-duckpam.md`](08-duckpam.md) |
| Q9 | Root key rotation after compromise | Re-wrap group keys and shares; migration UX and detection. | [`08-duckpam.md`](08-duckpam.md), [`09-contacts.md`](09-contacts.md) |
| Q10 | KEM library choice and audit | NTRU-HPS-2048-509 implementation, constant-time properties, upstream audit status. | [`08-duckpam.md`](08-duckpam.md) |
| Q11 | Hosted Netmaker controller as optional convenience | Self-hosted remains default; if offered, must be clearly labelled and minimise metadata. | [`10-ducknet.md`](10-ducknet.md) |
| Q12 | Mobile and roaming peers | Phone clients, key storage on mobile, roaming across networks. | [`10-ducknet.md`](10-ducknet.md) |
| Q13 | IPv6 in DuckNet | Desirable but not required for first release. | [`10-ducknet.md`](10-ducknet.md) |

## Features and platform

| # | Question | Options / notes | Owner doc |
| --- | --- | --- | --- |
| Q14 | VM and Kubernetes deployment scope | Deferred by decision; revisit after Nix + containers are solid. | [`12-app-deployment.md`](12-app-deployment.md) |
| Q15 | Output modules / stream handlers in the WM | Exploratory; needs its own design doc before work starts. | [`12-app-deployment.md`](12-app-deployment.md) |
| Q16 | Cross-device Contacts sync protocol | End-to-end encrypted sync between a user's own devices. | [`09-contacts.md`](09-contacts.md) |
| Q17 | Group recovery when all admins are lost | Emergency admin key vs trusted-contacts path. | [`09-contacts.md`](09-contacts.md) |
| Q18 | vCard import / export | Interop with existing address books. | [`09-contacts.md`](09-contacts.md) |
| Q19 | Default group storage server package | Ship a packaged server vs require users to host one. | [`11-file-sharing.md`](11-file-sharing.md) |
| Q20 | Large-file and deduplication behaviour | Chunking, dedupe across groups, quota accounting. | [`11-file-sharing.md`](11-file-sharing.md) |

## Operations and polish

| # | Question | Options / notes | Owner doc |
| --- | --- | --- | --- |
| Q21 | CI for eval, ISO build, smoke tests, signing | No pipeline today; needed for the release checklist. | [`13-release-and-support.md`](13-release-and-support.md) |
| Q22 | aarch64 build and test infrastructure | Native ARM builder vs emulated binfmt builds. | [`13-release-and-support.md`](13-release-and-support.md) |
| Q23 | Published security contact and advisory process | Private reporting channel, acknowledgement and disclosure policy. | [`13-release-and-support.md`](13-release-and-support.md) |
| Q24 | Replace placeholder URLs and finish branding artwork | `example.org` links, product banner/wallpaper, installer screenshots. | [`06-user-experience.md`](06-user-experience.md) |
| Q25 | Custom GRUB theme and Plymouth logo | Currently uses NixOS defaults with Rix distro name. | [`06-user-experience.md`](06-user-experience.md) |
| Q26 | Tvix re-evaluation trigger | Revisit when flake/fetcher support and a packaged build exist. See [`../docs/tvix.md`](../docs/tvix.md). | [`00-overview.md`](00-overview.md) |

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
