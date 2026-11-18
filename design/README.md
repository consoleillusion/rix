# Rix design documentation

This directory is the **source of truth for Rix's design**. It describes the
system we are building, why it is built that way, and which parts already exist
in this repository.

It is deliberately separate from:

| Document | Purpose |
| --- | --- |
| [`../README.md`](../README.md) | Build, run and customise the live ISO today. |
| [`../contacts.md`](../contacts.md) | Raw product vision for Contacts and relationship-based computing. |
| [`../duckpam.md`](../duckpam.md) | Raw technical notes for DuckPAM. |
| [`../docs/tvix.md`](../docs/tvix.md) | Why Tvix is not on the installer critical path. |

Where a design document and a raw vision note disagree, **the design document
wins**; update the vision note instead of leaving two conflicting statements.

## Audience

Primarily **implementers** — people adding modules, services and UI. Each doc is
written so that the overview can be read by anyone, while the feature docs
carry enough detail to guide implementation. A glossary is provided in
[`14-glossary.md`](14-glossary.md).

## North star

> A stable, secure, modern replacement for Windows for everyday users — with
> usable security and stability by default, and no rough edges that demand Nix
> or Arch expertise.

Rix is NixOS-based with flakes enabled by default. NixOS supplies the
foundation (declarative configuration, atomic updates, rollback); Rix supplies
the curation, the friendly GUI configuration layer, and the relationship,
identity and sharing features that make it a complete desktop OS. See
[`00-overview.md`](00-overview.md) and [`01-principles.md`](01-principles.md).

## Status labels

Every document carries a small metadata block:

```
> **Status:** Current | Mixed | Design
> **Last updated:** YYYY-MM-DD
> **See also:** ...
```

| Status | Meaning |
| --- | --- |
| `Current` | Describes behaviour that is implemented in this repository. |
| `Mixed` | Some of it exists; the rest is the agreed target design. |
| `Design` | Agreed target design; not yet implemented. |

`Design` is not the same as "unknown": it is a decision that has been made and
should be implemented as written. Undecided items go in
[`15-open-questions.md`](15-open-questions.md), not silently into a doc.

## Document index

| # | Document | Status | Covers |
| --- | --- | --- | --- |
| 00 | [Overview](00-overview.md) | Mixed | What Rix is, what NixOS gives us, goals and non-goals. |
| 01 | [Principles](01-principles.md) | Design | The rules that drive design decisions. |
| 02 | [Architecture](02-architecture.md) | Mixed | Build, live image, installed system, configuration stack, layers. |
| 03 | [Threat model](03-threat-model.md) | Design | Assets, adversaries, trust boundaries, attack scenarios. |
| 04 | [Security defaults](04-security-defaults.md) | Mixed | Concrete default settings and their escape hatches. |
| 05 | [Stability and updates](05-stability-and-updates.md) | Mixed | Atomic updates, automatic updates, rollback, testing. |
| 06 | [User experience](06-user-experience.md) | Design | Everyday journeys, GUI configuration, no rough edges. |
| 07 | [Installer and first boot](07-installer-and-first-boot.md) | Mixed | Live ISO, Calamares, encryption, identity setup, onboarding. |
| 08 | [DuckPAM](08-duckpam.md) | Design | Password-unlocked post-quantum identity, ducklings, recovery. |
| 09 | [Contacts](09-contacts.md) | Design | People, groups, identity, relationship-based access. |
| 10 | [DuckNet](10-ducknet.md) | Design | Self-hosted Netmaker/WireGuard mesh networking. |
| 11 | [File sharing](11-file-sharing.md) | Design | Iroh P2P, group storage, pinning, notifications. |
| 12 | [App deployment](12-app-deployment.md) | Design | Nix modules and containers first; VMs and Kubernetes later. |
| 13 | [Release and support](13-release-and-support.md) | Mixed | Versioning, channels, support window, security response. |
| 14 | [Glossary](14-glossary.md) | Current | Terms used across the design docs. |
| 15 | [Open questions](15-open-questions.md) | Design | Undecided items and decisions still to make. |

## Maintenance rules

1. **One concern per file.** If a doc starts covering two topics, split it.
2. **Code and docs move together.** Changing a default, flow or data model
   means updating the relevant doc in the same commit. Use a conventional
   commit prefix such as `docs(design): clarify update rollback policy`; this
   keeps each file's history readable.
3. **Link, do not copy.** Point to source files (e.g. `../modules/common.nix`)
   rather than duplicating code. Duplicate facts drift.
4. **Update the metadata block** when a doc changes, including its status.
5. **Resolve decisions in the right place.** New decisions update the owning
   doc and remove the corresponding entry from
   [`15-open-questions.md`](15-open-questions.md).
6. **Keep claims honest.** Distinguish what exists now from what is planned;
   do not claim guarantees the implementation cannot yet provide.

## Suggested reading order

Implementers new to the project: **00 → 01 → 02 → 03 → 04 → 05 → 06 → 07**,
then whichever feature docs they are working on (**08–12**), then **13–15**.
