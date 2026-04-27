# User experience

> **Status:** Design
> **Last updated:** 2026-11-18
> **See also:** [Principles](principles.md), [Architecture](architecture.md), [Installer and first boot](installer-and-first-boot.md)

Rix is for people who want a computer that simply works: friends and family,
privacy-aware individuals and small groups. The benchmark is a modern Windows
desktop, without the rough edges of a bare NixOS or Arch installation.

## Experience goals

1. **Nothing Nix-shaped in the normal path.** No store paths, generation
   numbers, unit names or Nix syntax in everyday screens.
2. **Familiar structure.** Plasma 6 desktop, application grid, system settings,
   file manager, notifications and a software centre.
3. **Safe choices made for the user.** Secure defaults with a short, plain
   explanation when something is blocked.
4. **Every change is understandable and reversible.** A settings change shows
   what will happen and can be undone.
5. **Errors are actionable.** "What happened, what it affected, what to try
   next" — never a raw stack trace.

## Target users and their needs

| User | Need | Design response |
| --- | --- | --- |
| Friends & family | Share photos, files and app access without admin work. | Group-based sharing in the file manager; invitations by contact; no server setup. |
| Privacy-aware individual | Control over data and updates, no telemetry. | Local-first storage, no analytics, transparent permissions, self-hosted controller. |
| Small group / household | Shared resources and simple administration. | Group roles (member/admin), shared storage and app deployment, visible audit history. |

## Key journeys

### First boot

1. Boot the installed system; choose the user account.
2. A short setup wizard: confirm identity name, create or import identity,
   generate and store recovery codes, choose privacy options, optionally add
   trusted contacts, join or create a group.
3. Land on a normal Plasma desktop with a "Getting started" card linking to
   Contacts, File Manager and Software Centre.

### Daily use

- Notifications show group activity, shares and update status.
- Software Centre installs apps in one click, with a permission summary before
  install.
- Rix Settings exposes system controls in sections: Users, Security, Network,
  Groups, Updates, Apps, Advanced.

### Adding a friend

1. Open Contacts → Add contact → exchange a public-key fingerprint (scan a QR
   code or read a safety number).
2. Verify out of band; the contact is marked verified.
3. Add them to a group; network and file access follow automatically.

### Sharing a file

1. In the file manager, select file(s) → Share.
2. Pick a contact or group.
3. Choose direct link, group storage or peer-to-peer replication; set expiry.
4. The recipient gets a notification through their preferred channel.

### Installing an app

1. Software Centre lists reviewed apps with permission summaries.
2. One click installs; the GUI shows source, version, group availability and
   permissions.
3. Updates and rollback are handled like system updates.

### Recovery

1. User clicks "I can't log in" or uses a recovery code at the login screen.
2. Recovery codes restore identity; trusted-contacts recovery walks through
   the threshold flow if enabled.
3. A security notice shows when and how recovery was used.

## GUI configuration frontend (the central UX piece)

The GUI is the primary way to configure Rix. Internally it is a thin, typed
frontend over Nix modules:

```
User clicks a toggle
  → typed setting in Rix settings model
  → preview: "This will enable SSH and open port 22"
  → one nixos-rebuild transaction
  → boot entry + rollback button
```

Requirements:

- **Typed settings.** Each setting has a schema, validation and a default.
- **Preview/diff.** Before applying, show a readable summary and the generated
  Nix in the Advanced view.
- **Atomic apply.** All changes in one rebuild; no partial states.
- **Rollback button.** Same mechanism as the boot menu.
- **Power-user parity.** Everything the GUI does is available via CLI and
  Nix modules; no hidden state.
- **Import/export.** Settings can be exported as a Nix module for version
  control, matching the flake-based system design.

See [`architecture.md`](architecture.md) for the stack and
[`security-defaults.md`](security-defaults.md) for what is configurable.

## Writing and tone

- Use "Rix" for the OS, "NixOS" when referring to the underlying system.
- Prefer short sentences and concrete verbs: "Share with Friends", not
  "Configure resource distribution policy".
- Explain security in terms of the user's outcome: "Only people in Friends can
  open this", not "E2EE with recipient-bound wrapping keys".
- Placeholders (example.org URLs, unfinished artwork) must not ship in a
  release; they are tracked in [`open-questions.md`](open-questions.md).

## Accessibility and inclusion

- Full keyboard navigation and screen-reader support in Plasma and Rix apps.
- High-contrast themes, scalable text and remappable shortcuts.
- Localisation-ready strings from the start; no English-only idioms in core
  flows.
- Clear visual distinction between admin and normal actions.

## Installer notes

The current live ISO uses Calamares with Rix branding. Icicle
(<https://github.com/snowfallorg/icicle>) has similar goals and may be a better
long-term installer, but it must be evaluated against our requirements before
replacing Calamares. The decision is tracked in
[`open-questions.md`](open-questions.md). Installation flow details are
in [`installer-and-first-boot.md`](installer-and-first-boot.md).
