# Contacts

> **Status:** Design
> **Last updated:** 2026-11-18
> **See also:** [Overview](../contacts), [DuckPAM](duckpam), [DuckNet](ducknet), [File sharing](file-sharing)

Contacts is Rix's relationship layer: people and groups are first-class
entities that drive network, file and application access. It is the user-facing
implementation of the vision in [`../contacts`](../contacts).

## Goals

- A familiar, Telegram-like address book for individuals and organisations.
- Groups are real objects with their own resources, not just labels.
- One identity model shared by authentication, networking, sharing and apps.
- Local-first: no Rix-operated directory is required.
- Metadata-minimising: public keys, not real-world identities, are the wire
  identifiers.

## Data model

### Contact

| Field | Purpose |
| --- | --- |
| `id` | Stable local identifier. |
| `displayName` | User-chosen label. |
| `publicKey` | DuckPAM root identity public key ([`duckpam`](duckpam)). |
| `fingerprint` | Human-checkable representation of the public key (safety number). |
| `verification` | `unverified` / `verified` after out-of-band check. |
| `devices` | Per-device public keys; individually revocable. |
| `preferredChannel` | Default notification method (Telegram, SMS, email, in-app). |
| `groups` | Memberships, each with a role. |

### Group

| Field | Purpose |
| --- | --- |
| `id` | Stable identifier, local to the user's view. |
| `displayName` | e.g. "Friends", "Work". |
| `members` | Contacts plus roles (`member`, `admin`). |
| `identity` | Group key pair; group public key names the group to other services. |
| `network` | DuckNet address space and policy ([`ducknet`](ducknet)). |
| `resources` | Shared folders, apps and services assigned to the group. |
| `policies` | Permissions, quotas, expiry defaults, audit settings. |

### Membership

A contact can belong to many groups at once. Membership is the authorisation
record: adding someone to "Friends" grants the network and file access defined
by that group; removing them revokes it. Membership changes are signed by a
group admin and propagated to dependent services.

## Identity and verification

- The user's identifier is the DuckPAM root public key, not an email address
  or phone number.
- Adding a contact means exchanging public keys; the fingerprint is verified
  out of band (QR scan or reading a safety number aloud).
- Unverified contacts can be used but are visibly marked until verified.
- Per-device keys let a user add a phone or laptop and revoke it later without
  changing the root identity.
- Key rotation is supported; the old key is marked retired and group
  membership is re-wrapped to the new key.

## Group-driven access

```
        Contacts / Groups
                │
   ┌────────────┼────────────────┐
   ▼            ▼                ▼
DuckNet     File sharing     App deployment
(membership (share targets) (group-scoped
 → peers)                    services)
   │
   └────────── communication preferences ──► notifications
```

Consequences:

- **Network:** joining a group provisions a WireGuard peer in that group's
  network. Leaving removes it ([`ducknet`](ducknet)).
- **Files:** sharing with a group wraps content keys to group member keys;
  revocation re-wraps and expires tickets ([`file-sharing`](file-sharing)).
- **Apps:** deploying an app to a group makes its service reachable only by
  group members through DuckNet ([`app-deployment`](app-deployment)).
- **Notifications:** each contact's preferred channel selects how share
  links and invitations are delivered.

## User experience

- Contact list and group list with search, favourites and avatars.
- "Add contact" by QR code, fingerprint, or imported key file.
- Group creation wizard: name, members, optional network and storage settings.
- Member roles visible and changeable by admins.
- Clear status: online via group network, last seen, verified/unverified.
- An audit view for admins: who joined, who was removed, who changed a policy.

The UI wording follows [`user-experience`](user-experience):
outcomes first, cryptography second.

## Privacy and trust model

- No central directory is required; contact data lives on the user's devices.
- Contacts may be synced end-to-end encrypted between a user's own devices.
- The wire format uses public keys and opaque group ids; display names are not
  broadcast unnecessarily.
- Group admins can add/remove members and set policy, but cannot read private
  messages between members.
- A compromised admin can revoke access or deploy a malicious group app; the
  UI surfaces these events rather than applying them silently.
- Invitations expire and are single-use.

## Failure modes

| Failure | Response |
| --- | --- |
| Lost device key | Revoke that device from the contact record; other devices keep access. |
| Lost root identity | Recovery codes or trusted contacts ([`duckpam`](duckpam)). |
| Malicious invite | Show fingerprint and group origin; require explicit acceptance. |
| Controller offline | Cached membership continues to work; changes queue until reconnect. |
| Conflicting membership updates | Signed, timestamped updates with conflict visible to admins. |

## Open items

Tracked in [`open-questions`](open-questions): cross-device sync
protocol, key-rotation UX, group recovery when all admins are lost, and
optional vCard import/export.
