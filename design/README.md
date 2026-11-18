# Rix design documentation

This directory is the **source of truth for Rix's design**. It describes the
system we are building, why it is built that way, and which parts already exist
in this repository.

It is deliberately separate from:

| Document | Purpose |
| --- | --- |
| [`./contacts_notes`](./contacts) | Raw product vision for Contacts and relationship-based computing. |
| [`./duckpam_notes`](./duckpam) | Raw technical notes for DuckPAM. |
| [`./tvix`](./tvix) | Why Tvix is not on the installer critical path. |

Where a design document and a raw vision note disagree, **the design document
wins**; update the vision note instead of leaving two conflicting statements.

## Audience

Primarily **implementers** — people adding modules, services and UI. Each doc is
written so that the overview can be read by anyone, while the feature docs
carry enough detail to guide implementation. A glossary is provided in
[`glossary`](glossary).

## North star

> A stable, secure, modern replacement for Windows for everyday users — with
> usable security and stability by default, and no rough edges that demand Nix
> or Arch expertise.

Rix is NixOS-based with flakes enabled by default. NixOS supplies the
foundation (declarative configuration, atomic updates, rollback); Rix supplies
the curation, the friendly GUI configuration layer, and the relationship,
identity and sharing features that make it a complete desktop OS. See
[`overview`](overview) and [`principles`](principles).

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
[`open-questions`](open-questions), not silently into a doc.

## Document index

| Document | Status | Covers |
| --- | --- | --- |
| [Overview](overview) | Mixed | What Rix is, what NixOS gives us, goals and non-goals. |
| [Principles](principles) | Design | The rules that drive design decisions. |
| [Architecture](architecture) | Mixed | Build, live image, installed system, configuration stack, layers. |
| [Threat model](threat-model) | Design | Assets, adversaries, trust boundaries, attack scenarios. |
| [Security defaults](security-defaults) | Mixed | Concrete default settings and their escape hatches. |
| [Stability and updates](stability-and-updates) | Mixed | Atomic updates, automatic updates, rollback, testing. |
| [User experience](user-experience) | Design | Everyday journeys, GUI configuration, no rough edges. |
| [Installer and first boot](installer-and-first-boot) | Mixed | Live ISO, Calamares, encryption, identity setup, onboarding. |
| [DuckPAM](duckpam) | Design | Password-unlocked post-quantum identity, ducklings, recovery. |
| [Contacts](contacts) | Design | People, groups, identity, relationship-based access. |
| [DuckNet](ducknet) | Design | Self-hosted Netmaker/WireGuard mesh networking. |
| [File sharing](file-sharing) | Design | Iroh P2P, group storage, pinning, notifications. |
| [App deployment](app-deployment) | Design | Nix modules and containers first; VMs and Kubernetes later. |
| [Release and support](release-and-support) | Mixed | Versioning, channels, support window, security response. |
| [Glossary](glossary) | Current | Terms used across the design docs. |
| [Open questions](open-questions) | Design | Undecided items and decisions still to make. |

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
  [`open-questions`](open-questions).
- **Keep claims honest.** Distinguish what exists now from what is planned;
  do not claim guarantees the implementation cannot yet provide.

## Suggested reading order

This is the order we recommend, expressed purely as a sequence of links here in
the README. It is a suggestion, not a constraint: every doc stands alone and
can be opened directly by name in whatever order the task requires. Changing
the recommendation means editing this paragraph, not renaming files.

[Overview](overview) → [Principles](principles) →
[Architecture](architecture) → [Threat model](threat-model) →
[Security defaults](security-defaults) →
[Stability and updates](stability-and-updates) →
[User experience](user-experience) →
[Installer and first boot](installer-and-first-boot) →
[DuckPAM](duckpam) → [Contacts](contacts) → [DuckNet](ducknet) →
[File sharing](file-sharing) → [App deployment](app-deployment) →
[Release and support](release-and-support) → [Glossary](glossary) →
[Open questions](open-questions).
