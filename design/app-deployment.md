# App deployment

> **Status:** Design
> **Last updated:** 2026-11-18
> **See also:** [Architecture](architecture), [Security defaults](security-defaults), [Contacts](contacts), [DuckNet](ducknet)

Rix lets users deploy and access applications through a local software
interface. Applications can be assigned to groups so their services are
available only to the right participants. The first design pass covers
declarative Nix modules and OCI containers; VMs and Kubernetes are later.

## Scope

| Target | Phase |
| --- | --- |
| Declarative Nix expressions / modules | First pass |
| OCI containers | First pass |
| Lightweight virtual machines | Later |
| Kubernetes pods | Later |
| Output modules (streams exposed to the window manager) | Later, exploratory |

This ordering follows the agreed decision: get Nix + containers right before
adding heavier orchestration. Kubernetes is not what makes Rix useful for
everyday users, and premature support would hurt stability.

## App descriptor

Each app in the catalogue has a versioned descriptor:

| Field | Purpose |
| --- | --- |
| `id`, `name`, `version` | Identity and display. |
| `source` | Nix expression or container image reference, pinned by hash. |
| `configSchema` | Typed settings shown in the GUI. |
| `permissions` | Files, network, devices, secrets; least-privilege defaults. |
| `group` | Which Contacts group may access the app's service. |
| `resources` | CPU, memory, disk and network limits. |
| `dataVolume` | Persistent storage with backup/pinning options. |
| `updatePolicy` | Who publishes updates and how they are verified. |
| `signature` | Catalogue maintainer signature over the descriptor and source. |

## Security defaults for apps

- **No privileged containers.** No host network, no host PID, no Docker socket.
- **Sandboxing.** Per-app identity and data directory; portal-mediated access
  to files, camera, microphone and screen.
- **Read-only root filesystem** where the image supports it; only the data
  volume is writable.
- **Scoped secrets.** Credentials are injected at runtime from DuckPAM
  ducklings, never baked into images or stored in the Nix store
  ([`duckpam`](duckpam)).
- **Network policy.** Apps listen only on their group's DuckNet address unless
  explicitly allowed; no internet exposure by default
  ([`ducknet`](ducknet)).
- **Signed sources.** Image digests pinned in the descriptor; Nix inputs pinned
  by `flake.lock`.
- **Resource limits.** Quotas prevent a single app from starving the desktop.
- **Unfree software** is opt-in and visibly marked, matching
  [`../modules/common.nix`](../modules/common.nix).

## Lifecycle

1. **Discover** — Software Centre lists reviewed apps with permission
   summaries.
2. **Install** — one click; GUI shows source, size, permissions and group
   assignment before confirm.
3. **Configure** — typed settings from the descriptor; generated Nix shown in
   Advanced view.
4. **Update** — atomic, staged with system updates; rollback to previous
   version.
5. **Stop / start / rollback / uninstall** — all available in the GUI with
   data-retention choices.
6. **Audit** — installs, updates and permission changes are recorded locally.

## Group-scoped services

Assigning an app to a group means:

- its service is reachable only from peers in that group via DuckNet;
- group admins can see and manage its status;
- sharing its output files uses the group's file-sharing policy
  ([`file-sharing`](file-sharing));
- removing the group revokes access and stops the service if configured.

Example: a Jellyfin server for Friends, a private Git server for Work, or a
shared document app for both — as in [`../contacts`](../contacts).

## Catalogue governance

- Descriptors are reviewed and signed by Rix maintainers.
- Every app has an owner and an update cadence; stale apps are marked.
- Security updates are prioritised like system updates.
- Users may add their own sources; the GUI labels them "unverified" and shows
  the signature status.
- Container images are pinned by digest, not floating tags.

## Output modules (future, exploratory)

Containers can expose output modules — network traffic or plain streams of
data — that handlers can attach to, potentially integrated into the window
manager. A Hyprland-like permission model could govern screengrab or inputgrab
per app. This is noted in [`../contacts`](../contacts) and is
**not** part of the first pass; it needs its own design doc before work starts.

## Integration summary

| Component | Integration |
| --- | --- |
| Contacts | Group assignment and access control. |
| DuckNet | Private service reachability. |
| DuckPAM | Runtime secret injection. |
| File sharing | App output and persistent data sharing. |
| Rix Settings / Software Centre | Install, configure, update, rollback. |

## Open items

Tracked in [`open-questions`](open-questions): VM and Kubernetes
scope, local build of custom Nix expressions, and resource policy on low-end
hardware.
