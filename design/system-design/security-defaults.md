# Security defaults

> **Status:** Mixed
> **Last updated:** 2026-11-18
> **See also:** [Threat model](threat-model.md), [Installer and first boot](../experience/installer-and-first-boot.md), [Stability and updates](stability-and-updates.md)

This is the concrete list of out-of-box security settings for an installed SekkOS
system. `Current` means the behaviour exists in this repository; `Design`
means it is the agreed target. Every default has a rationale and an explicit
escape hatch so that security does not become a trap.

## Defaults table

| Area | Default | Status | Rationale | Escape hatch |
| --- | --- | --- | --- | --- |
| System foundation | NixOS with flakes and `nix-command` enabled | Current | Declarative, atomic, reproducible; see [`../../modules/common.nix`](../../modules/common.nix). | Disable in a custom module (not recommended). |
| Input pinning | `flake.lock` committed with the installed system | Design (first rebuild creates it) | Reproducible known-good state. | `nix flake update --flake /etc/nixos`. |
| Full-disk encryption | LUKS2 with user passphrase plus a generated recovery key | Design | Protects stolen/offline device; avoids single point of failure. | Installer offers "no encryption" with a clear warning. |
| TPM2 | Auto-unlock only when a usable TPM2 is present; recovery key still required | Design | Removes daily friction without weakening recovery. | Disable TPM enrolment in installer. |
| Secure Boot | Enrol user-owned keys via lanzaboote when supported; graceful fallback when not | Design | Blocks bootkit-class attacks on modern hardware. | Keep vendor keys / disable on unsupported hardware. |
| Host firewall | Stateful firewall enabled, inbound denied by default | Current in pinned nixpkgs | Blocks unsolicited network access. | Open specific ports via NixOS options/GUI. |
| Remote access | SSH and remote desktop off unless explicitly enabled | Design | Reduces attack surface for home users. | Toggle in GUI Settings. |
| Administrative access | No passwordless `sudo` for desktop user; Polkit prompts for admin actions | Design | Limits accidental and malicious privilege use. | Advanced users can add a rule. |
| Unfree software | `allowUnfree = false` by default | Current | Keeps the default closure auditable and free. | Per-package overrides with a visible notice. |
| Telemetry | None — no analytics, no usage reporting, no advertising IDs | Design | Privacy as a default. | No opt-in in the base system. |
| Updates | Automatic atomic updates with rollback; apply at next boot by default | Design | Security fixes land without user toil; failures are reversible. | Pause or switch to manual in GUI. |
| App sandboxing | Apps run with per-app identity, data directory and portal-mediated access | Design | Contains malicious apps. | Per-app permission editor in GUI. |
| Secrets | Never in `/nix/store` or GUI config; injected at runtime via DuckPAM | Design | Prevents accidental secret leakage through generations. | Advanced users may use their own secret store. |
| Screen lock | Auto-lock after inactivity and on suspend; password required to resume | Design | Limits unlocked-device theft. | Configurable timeout; never disabled without confirmation. |
| Browser | Hardened defaults: no third-party trackers by default, HTTPS-first, no auto-open of unknown file types | Design | Common attack path for everyday users. | Per-site exceptions. |
| Logging | Local, privacy-preserving logs; no upload; redact secrets | Design | Useful diagnostics without surveillance. | Optional debug logging with expiry. |
| Identity | Root identity is the DuckPAM NTRU key; public key is the user identifier | Design | Phishing-resistant, post-quantum identity. | Multiple identities per user are supported. |
| Recovery | Recovery codes generated at first login; trusted contacts opt-in | Design | Prevents permanent lockout. | User may add trusted contacts later. |
| Group access | Membership in Contacts groups governs network, file and app access | Design | One consistent access-control model. | Per-resource overrides for advanced users. |

## Notes on key defaults

### Encryption and recovery

Encryption is only useful if the user can still get in. The installer generates
a recovery key alongside the passphrase and walks the user through storing it
offline (print or write down). Where TPM2 is available it is used for
transparent unlock, but the recovery key remains valid. Trusted-contacts
recovery is deliberately **opt-in**, because it exposes the user's social graph
to the recovery protocol; see [`duckpam`](../identity/duckpam.md).

### Automatic updates without surprises

Updates are built and verified before they are applied. The default is to stage
them for the next boot (`operation = "boot"` in NixOS terms) and notify the
user, so an update never interrupts active work. A failed boot rolls back to
the previous generation. Full policy in
[`stability-and-updates`](stability-and-updates.md).

### Application permissions

The GUI presents permissions the way a phone does: camera, microphone, screen,
files, network. Requests are scoped to an app identity and revocable. This is
the main mechanism for the "malicious app" scenario in
[`threat-model`](threat-model.md).

### Remaining NixOS rough edges to hide

The following must never surface in the normal UI: store paths, generation
numbers as opaque strings, `nix-rebuild` output, unit names, and raw Nix errors.
The GUI translates them into "what changed, what will restart, and what to do
if it fails".

## Verification

Each default needs a test in CI or the release checklist:

- encryption: ISO boots, LUKS unlock with passphrase and recovery key both work;
- firewall: unsolicited inbound port is closed out of the box;
- updates: a deliberately broken generation rolls back;
- secrets: `grep` of a built closure finds no test secret;
- telemetry: no outbound connection to SekkOS-controlled endpoints on a fresh boot.
