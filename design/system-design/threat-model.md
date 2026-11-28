# Threat model

> **Status:** Design
> **Last updated:** 2026-11-18
> **See also:** [Security defaults](security-defaults.md), [Architecture](architecture.md), [DuckPAM](../identity/duckpam.md)

This document defines what SekkOS protects, from whom, and with which mechanisms.
It is the basis for the defaults in
[`security-defaults`](security-defaults.md) and the app rules in
[`app-deployment`](../services/app-deployment.md).

## Assets

| Asset | Why it matters |
| --- | --- |
| User data (files, photos, messages) | Loss or exposure is the most direct harm to an everyday user. |
| Cryptographic identity and keys | The DuckPAM root key authenticates the user and unlocks derived secrets; theft enables impersonation. |
| Group membership and social graph | Reveals relationships and organisational structure even when content is encrypted. |
| System integrity | A modified system binary or update undermines every other guarantee. |
| Availability | Ransomware, a broken update or a lost controller must not leave the user with an unusable machine. |
| Recovery material | Recovery codes and trusted-contacts shares are as sensitive as the primary key. |
| Physical device | A stolen laptop must not yield data or long-lived credentials. |

## Adversaries

| Adversary | Capability | Primary concern |
| --- | --- | --- |
| Malicious or compromised application | Runs with the user's privileges; may try to read other apps' data, persist, or escalate. | Data theft, privilege escalation, ransomware. |
| Network attacker | Controls Wi-Fi, DNS or an internet path; can observe, redirect or inject traffic. | Eavesdropping, MITM, phishing of identity flows. |
| Service operator | Runs a Netmaker controller, relay, directory or update mirror used by a group. | Metadata collection, malicious config push, denial of service. |
| Physical thief | Has the powered-off device, or briefly the unlocked device. | Offline disk access, unlocked-session abuse. |
| Supply-chain attacker | Compromises a package, flake input, build step or distribution channel. | Backdoored system or update. |
| Malicious or compromised group member | Is legitimately inside a group. | Abuse of shared files, apps or network access; flooding; revocation attacks. |
| Curious cloud/storage provider | Hosts ciphertext or backups for the user. | Metadata inference; coercion to disclose. |

## Trust boundaries

| Boundary | Crossing | Enforcement |
| --- | --- | --- |
| Application ↔ OS | An app requests files, screen, input, network, secrets. | Wayland portals, per-app sandbox, Polkit, scoped DuckPAM secrets. |
| Application ↔ application | An app tries to read another app's data or identity. | Separate per-app identities and data directories; no shared user-wide secret store without mediation. |
| Device ↔ network | Traffic leaves the machine. | Host firewall (on by default), WireGuard mesh, TLS with pinned trust where feasible. |
| User ↔ controller | Netmaker controller distributes peer config. | Self-hosted controller; signed/minimal config; no trust required for traffic confidentiality. |
| User ↔ group member | Invitations, shares, membership changes. | Public-key identity, out-of-band verification, cryptographic authorisation, revocation. |
| Build inputs ↔ store | Flake inputs become system closures. | `flake.lock` hashes, isolated builds, patch dry-runs, CI verification, signed artifacts (future). |
| Login ↔ keys | Password unlocks identity. | Argon2 + AES-256-GCM in DuckPAM; rate limiting; key material cleared where possible. |
| Recovery ↔ identity | Recovery codes or trusted contacts rebuild access. | Single-use codes, threshold splitting, audited use, no SekkOS escrow. |

## Attack scenarios and mitigations

### Malicious application reads the user's documents

**Attack.** A downloaded app scans the home directory and exfiltrates files.

**Mitigation.** Apps run sandboxed with per-app data directories by default;
file access goes through a portal that requires an explicit user pick; the
firewall limits outbound traffic where policy allows; secrets are delivered
per-app at login rather than sitting in a readable file. See
[`app-deployment`](../services/app-deployment.md).

**Residual risk.** An app the user explicitly grants broad access to can still
read those files. The UI must make the grant visible and revocable.

### Privilege escalation

**Attack.** An app exploits a setuid helper or a misconfigured service to gain
root and rewrite system files.

**Mitigation.** `/nix/store` is read-only and content-addressed; services run
unprivileged with systemd sandboxing; Polkit governs administrative actions;
no passwordless `sudo` for the desktop user; unexpected store changes are
detectable because rebuilds are reproducible from the flake.

### Network eavesdropping or MITM

**Attack.** A hostile Wi-Fi network intercepts traffic or redirects a software
catalogue request.

**Mitigation.** Group traffic travels inside WireGuard; application traffic
uses TLS with a trusted CA set; downloads are verified by lockfile hashes; the
host firewall is on by default; a kill-switch option prevents traffic escaping
the mesh when policy requires it. See [`ducknet`](../services/ducknet.md).

**Residual risk.** A compromised CA or a user-ignored certificate warning can
still defeat TLS; the UI must not train users to click through warnings.

### Stolen or lost device

**Attack.** An attacker boots or removes the disk from a powered-off laptop.

**Mitigation.** LUKS full-disk encryption with a passphrase and a recovery key
is the default; TPM2 auto-unlock is offered only when available and still
requires a recovery key; screen lock and auto-lock on suspend limit exposure of
an unlocked session. See [`security-defaults`](security-defaults.md).

**Residual risk.** A device stolen while unlocked is exposed until it locks;
cold-boot and hardware attacks are out of scope.

### Supply-chain compromise

**Attack.** A malicious package or flake input enters the ISO or an update.

**Mitigation.** Inputs pinned with `narHash` in `flake.lock`; isolated builds;
patches applied explicitly and failing loudly; unfree software opt-in; CI
smoke tests and reproducible-build checks; signed release artifacts (planned).
See [`release-and-support`](../operations/release-and-support.md).

**Residual risk.** A compromised upstream that produces a malicious build
which passes tests cannot be fully ruled out; defense is layered with sandboxing
so one bad package is not automatically root.

### Malicious update or broken rebuild

**Attack.** An update bricks the machine or installs a backdoor.

**Mitigation.** Updates are atomic NixOS generations; the previous generation
stays bootable; automatic updates build first and apply at boot; health checks
can roll back a failed boot; the GUI exposes a one-click rollback. See
[`stability-and-updates`](stability-and-updates.md).

### Service operator learns the social graph

**Attack.** The operator of a controller or relay correlates peer IPs and
membership to map relationships.

**Mitigation.** Controller is user- or group-self-hosted by default; file
contents are end-to-end encrypted via Iroh; identifiers are public keys rather
than real names; metadata minimisation is a design requirement in Contacts and
DuckNet. See [`contacts`](../identity/contacts.md) and
[`ducknet`](../services/ducknet.md).

**Residual risk.** Timing and connection metadata can remain visible to a
network observer; future work includes padding and relay mixes.

### Malicious group member

**Attack.** A member floods a share, deploys a hostile app, or tries to revoke
others illegitimately.

**Mitigation.** Role-based group permissions (member/admin), signed membership
changes, per-app resource limits, quotas, audit log visible to admins, and
revocation that propagates to network keys and share tickets.

### Lost password or device

**Attack.** Not an adversary, but a failure mode with security consequences:
users who fear lockout reuse weak passwords or write secrets insecurely.

**Mitigation.** Recovery codes are generated by default and stored offline;
trusted-contacts threshold recovery is opt-in; the GUI walks the user through
both at first login; changing a password re-encrypts the key without changing
the identity. See [`duckpam`](../identity/duckpam.md).

## Explicitly out of scope

- Protection against a user who voluntarily approves a malicious action in the
  GUI with full knowledge.
- Physical hardware attacks (DMA, firmware replacement, cold-boot) beyond
  Secure Boot and TPM support when available.
- Legal compulsion of a self-hosted operator outside SekkOS's control.
- Guaranteed anonymity against a global network observer.

## Design consequences

1. Every default in [`security-defaults`](security-defaults.md) must
   map to one or more scenarios above.
2. New features must add a row to the scenarios table when they introduce a
   new trust boundary.
3. Security claims in user-facing material must be traceable to a mitigation
   in this document.
