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
[`glossary.md`](glossary.md).

## North star

> A stable, secure, modern replacement for Windows for everyday users — with
> usable security and stability by default, and no rough edges that demand Nix
> or Arch expertise.

Rix is NixOS-based with flakes enabled by default. NixOS supplies the
foundation (declarative configuration, atomic updates, rollback); Rix supplies
the curation, the friendly GUI configuration layer, and the relationship,
identity and sharing features that make it a complete desktop OS. See
[`overview.md`](overview.md) and [`principles.md`](principles.md).

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
[`open-questions.md`](open-questions.md), not silently into a doc.

## Document index

| Document | Status | Covers |
| --- | --- | --- |
| [Overview](overview.md) | Mixed | What Rix is, what NixOS gives us, goals and non-goals. |
| [Principles](principles.md) | Design | The rules that drive design decisions. |
| [Architecture](architecture.md) | Mixed | Build, live image, installed system, configuration stack, layers. |
| [Threat model](threat-model.md) | Design | Assets, adversaries, trust boundaries, attack scenarios. |
| [Security defaults](security-defaults.md) | Mixed | Concrete default settings and their escape hatches. |
| [Stability and updates](stability-and-updates.md) | Mixed | Atomic updates, automatic updates, rollback, testing. |
| [User experience](user-experience.md) | Design | Everyday journeys, GUI configuration, no rough edges. |
| [Installer and first boot](installer-and-first-boot.md) | Mixed | Live ISO, Calamares, encryption, identity setup, onboarding. |
| [DuckPAM](duckpam.md) | Design | Password-unlocked post-quantum identity, ducklings, recovery. |
| [Contacts](contacts.md) | Design | People, groups, identity, relationship-based access. |
| [DuckNet](ducknet.md) | Design | Self-hosted Netmaker/WireGuard mesh networking. |
| [File sharing](file-sharing.md) | Design | Iroh P2P, group storage, pinning, notifications. |
| [App deployment](app-deployment.md) | Design | Nix modules and containers first; VMs and Kubernetes later. |
| [Release and support](release-and-support.md) | Mixed | Versioning, channels, support window, security response. |
| [Glossary](glossary.md) | Current | Terms used across the design docs. |
| [Open questions](open-questions.md) | Design | Undecided items and decisions still to make. |

## Maintenance rules

- **Descriptive names only.** Never prefix filenames with numbers or sequence
  markers. Numbers go stale as docs are added, reordered or removed, and make a
  file harder to find from a path or search. The recommended order lives in the
  link sequence below, where it can be changed without renaming files or
  breaking links. Name each file after its concern.
- **One concern per file.** If a doc starts covering two topics, split it.
- **Code and docs move together.** Changing a default, flow or data model
  means updating the relevant doc in the same commit. Use a conventional
  commit prefix such as `docs(design): clarify update rollback policy`; this
  keeps each file's history readable.
- **Link, do not copy.** Point to source files (e.g. `../modules/common.nix`)
  rather than duplicating code. Duplicate facts drift.
- **Update the metadata block** when a doc changes, including its status.
- **Resolve decisions in the right place.** New decisions update the owning
  doc and remove the corresponding entry from
  [`open-questions.md`](open-questions.md).
- **Keep claims honest.** Distinguish what exists now from what is planned;
  do not claim guarantees the implementation cannot yet provide.

## Suggested reading order

This is the order we recommend, expressed purely as a sequence of links here in
the README. It is a suggestion, not a constraint: every doc stands alone and
can be opened directly by name in whatever order the task requires. Changing
the recommendation means editing this paragraph, not renaming files.

[Overview](overview.md) → [Principles](principles.md) →
[Architecture](architecture.md) → [Threat model](threat-model.md) →
[Security defaults](security-defaults.md) →
[Stability and updates](stability-and-updates.md) →
[User experience](user-experience.md) →
[Installer and first boot](installer-and-first-boot.md) →
[DuckPAM](duckpam.md) → [Contacts](contacts.md) → [DuckNet](ducknet.md) →
[File sharing](file-sharing.md) → [App deployment](app-deployment.md) →
[Release and support](release-and-support.md) → [Glossary](glossary.md) →
[Open questions](open-questions.md).
