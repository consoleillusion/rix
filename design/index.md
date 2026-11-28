# SekkOS design

This directory is the **source of truth for what SekkOS should be**. It describes
the system we are building, why it is built that way, which decisions have
already been made, and which parts exist in this repository today. When code and
these documents disagree, the design document is the target and the code is the
thing to fix.

The index below is the canonical reading order. Chapters live at
`design/<part>/<chapter>.md`, where `<part>` is a descriptive folder name:
`foundations`, `system-design`, `experience`, `identity`, `services`,
`operations`, `reference`. Roman numerals are used only to label parts when the
book is laid out — they are not folder names. Chapters are named after their
concern, never after a number, so files can be added, reordered or renamed
without anything going out of sync. The same order drives
[`index.typ`](index.typ), which compiles the whole design into one PDF.

## Audience

Primarily implementers — people adding modules, services and UI. The overview
can be read by anyone; feature chapters carry enough detail to guide
implementation. Terms used throughout are collected in the
[glossary](reference/glossary.md).

## North star

> A stable, secure, modern replacement for Windows for everyday users — with
> usable security and stability by default, and no rough edges that demand Nix
> or Arch expertise.

SekkOS is NixOS-based with flakes enabled by default. NixOS supplies the
foundation (declarative configuration, atomic updates, rollback); SekkOS supplies
the curation, the friendly GUI configuration layer, and the relationship,
identity and sharing features that make it a complete desktop OS.

## Status labels

Every chapter carries a small metadata block:

```text
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
[open questions](operations/open-questions.md), not silently into a chapter.

## Part I — Vision and principles

- [Overview](foundations/overview.md) — what SekkOS is, what NixOS gives us, goals and non-goals.
- [Design principles](foundations/principles.md) — the rules that drive every design decision.

## Part II — System design

- [Architecture](system-design/architecture.md) — build, live image, installed system, configuration stack, layers.
- [Threat model](system-design/threat-model.md) — assets, adversaries, trust boundaries and attack scenarios.
- [Security defaults](system-design/security-defaults.md) — concrete defaults and their labelled escape hatches.
- [Stability and updates](system-design/stability-and-updates.md) — atomic updates, automatic updates, rollback and testing.

## Part III — User experience

- [User experience](experience/user-experience.md) — everyday journeys, GUI configuration, no rough edges.
- [Installer and first boot](experience/installer-and-first-boot.md) — live ISO, Calamares, encryption, identity setup and onboarding.

## Part IV — Identity and relationships

- [DuckPAM](identity/duckpam.md) — password-unlocked post-quantum identity, ducklings and recovery.
- [Contacts](identity/contacts.md) — people, groups, identity and relationship-based access.

## Part V — Shared services

- [DuckNet](services/ducknet.md) — self-hosted Netmaker/WireGuard mesh networking.
- [File sharing](services/file-sharing.md) — Iroh P2P, group storage and pinning.
- [Notifications and communications](services/notifications.md) — event delivery through contacts' preferred channels.
- [App deployment](services/app-deployment.md) — Nix modules and containers first; VMs and Kubernetes later.

## Part VI — Delivery and operations

- [Release and support](operations/release-and-support.md) — versioning, channels, support window and security response.
- [Open questions](operations/open-questions.md) — undecided items and decisions still to make.

## Part VII — Reference and background

- [Glossary](reference/glossary.md) — terms used across the design.
- [Tvix assessment](reference/tvix.md) — why Tvix is not on the installer critical path.
- [Contacts vision notes](reference/contacts-vision.md) — raw product vision behind the Contacts design.
- [DuckPAM research notes](reference/duckpam-research.md) — raw technical notes behind the DuckPAM design.

Part VII is reference material. The first two chapters are stable reference;
the last two are historical raw notes kept for provenance. Where a note and a
design chapter disagree, **the chapter wins** — update the note rather than
leaving two conflicting statements.

## Maintenance rules

- **Descriptive names only.** Never prefix filenames with numbers or sequence
  markers. Numbers go stale as docs are added, reordered or removed, and make a
  file harder to find from a path or search. The recommended order lives in this
  index, where it can be changed without renaming files or breaking links.
- **Parts are named by concern.** Add a chapter to an existing part folder, or
  create a new descriptively named folder when a new part is needed. The
  numerals written in the headings below are for readability; the PDF assigns
  its own from the part order, so the book can never drift out of sync. The
  chapter order in [`index.typ`](index.typ) follows this index automatically.
- **One concern per file.** If a chapter starts covering two topics, split it.
- **Code and docs move together.** Changing a default, flow or data model means
  updating the relevant chapter in the same commit. Use a conventional commit
  prefix such as `docs(design): clarify update rollback policy`.
- **Link, do not copy.** Point to source files (e.g. `../modules/common.nix`
  from a part folder) rather than duplicating code. Duplicate facts drift.
- **Update the metadata block** when a chapter changes, including its status.
- **Resolve decisions in the right place.** New decisions update the owning
  chapter and remove the corresponding entry from
  [open questions](operations/open-questions.md).
- **Keep claims honest.** Distinguish what exists now from what is planned; do
  not claim guarantees the implementation cannot yet provide.

## Building the PDF

`index.typ` reads this index, resolves the chapter links and renders every
chapter with Typst's `cmarker` plugin. From the repository root:

```console
$ npm run design:pdf
```

The result is `design/index.pdf`. It needs `typst` on `PATH`; the first build
also downloads `cmarker` from Typst's package registry unless it is cached.
