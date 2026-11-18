# Installer and first boot

> **Status:** Mixed
> **Last updated:** 2026-11-18
> **See also:** [Architecture](02-architecture.md), [Security defaults](04-security-defaults.md), [User experience](06-user-experience.md)

## Current state (implemented)

The live ISO is built from [`../flake.nix`](../flake.nix) and imports NixOS's
upstream `installation-cd-graphical-calamares-plasma6.nix` profile in
[`../profiles/live.nix`](../profiles/live.nix). That supplies the live `nixos`
user, auto-login, networking, hardware scanning, Plasma 6 and
`calamares-nixos`.

[`../modules/calamares.nix`](../modules/calamares.nix) overrides
`calamares-nixos-extensions` to:

- install the Rix branding from
  [`../calamares/branding/rix/`](../calamares/branding/rix/);
- switch `settings.conf` to `branding: rix`;
- replace `packagechooser.conf` with a Plasma-first chooser (ids `plasma6` and
  `""` must stay in sync with upstream `main.py`);
- apply
  [`../calamares/patches/installed-config-branding.patch`](../calamares/patches/installed-config-branding.patch)
  to the generated `configuration.nix` and write a `flake.nix` for the
  installed system.

The installed system is channel-based for the initial install and flake-based
from the first rebuild. This is a known, documented limitation in
[`../README.md`](../README.md).

## Target installation flow (Design)

1. **Boot.** BIOS/UEFI, x86_64 or aarch64; live user auto-logs into Plasma;
   Calamares (or its replacement) starts.
2. **Hardware check.** Warn clearly if TPM2 or Secure Boot support is
   unavailable; do not block installation.
3. **Disk selection.** Guided "erase disk / install alongside" and an advanced
   manual mode. Show exactly what will be erased.
4. **Encryption.** LUKS2 with a passphrase plus a generated recovery key.
   Offer TPM2 auto-unlock when available. "No encryption" requires an explicit
   confirmation.
5. **Account.** Real name, username, password; no empty-password account on
   installed systems.
6. **Identity.** Generate the DuckPAM NTRU keypair, encrypt it with the
   password, and store it in `/etc/duckshadow`. This becomes the user's root
   identity ([`08-duckpam.md`](08-duckpam.md)).
7. **Network.** Join an existing group network or create a new one; configure
   the self-hosted Netmaker controller if needed
   ([`10-ducknet.md`](10-ducknet.md)).
8. **Desktop choice.** Plasma 6 default, minimal console alternative.
9. **Install.** `nixos-install` writes `configuration.nix` and `flake.nix`
   with Rix branding; the first boot entry is created.
10. **Finish.** Reboot prompt with a reminder to store the recovery key.

## First-boot wizard (Design)

On first login the user completes:

1. **Recovery setup** — display recovery codes once, prompt the user to store
   them; optionally configure trusted-contacts recovery.
2. **Verification** — check the identity fingerprint displayed in Contacts.
3. **Privacy choices** — defaults already safe; the wizard explains what is
   local-only and what, if anything, is shared.
4. **Group setup** — create a personal group or join an invited one.
5. **Getting started** — links to file sharing, software centre and settings.

The wizard can be skipped by advanced users; skipping never leaves an
unprotected account, because encryption and identity are set up during
installation.

## Installer validation checklist

- ISO boots on BIOS and UEFI, x86_64 and aarch64.
- Calamares starts and uses Rix branding (no upstream NixOS artwork).
- Package chooser offers Plasma 6 and minimal system with working ids.
- Generated `configuration.nix` contains the Rix identity block.
- Generated `flake.nix` contains the correct release branch and target system.
- Patch applies cleanly to the pinned nixpkgs (`patch --dry-run` in CI).
- LUKS unlock works with both passphrase and recovery key.
- First boot reaches the desktop and the recovery wizard.
- Rollback entry exists before the wizard completes.

## Icicle consideration

SnowflakeOS has related goals but slower development; Icicle
(<https://github.com/snowfallorg/icicle>) may offer a nicer installation
experience. Replacing Calamares is **not** decided. Evaluate against: disk
encryption setup, flake-aware config generation, aarch64 support, branding,
maintenance effort, and the ability to reuse the Rix GUI settings components.
The decision lives in [`15-open-questions.md`](15-open-questions.md).
