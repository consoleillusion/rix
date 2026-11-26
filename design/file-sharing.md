# File sharing

> **Status:** Design
> **Last updated:** 2026-11-18
> **See also:** [Contacts](contacts), [DuckNet](ducknet), [Architecture](architecture), [../contacts](../contacts)

SekkOS file sharing is built into the file manager. Files can be shared with an
individual or a group, replicated peer-to-peer with Iroh, stored on a group
server, or pinned so that multiple independent copies persist.

## Goals

- Sharing is a native file-manager action, not a separate service.
- End-to-end encryption for all sharing modes.
- Group membership is the default permission model.
- Local-first: direct transfers work without a SekkOS cloud.
- Users can see how many independent copies of a pinned file exist.

## Sharing modes

| Mode | How it works | When to use |
| --- | --- | --- |
| **Direct share** | Generate a time-limited link/ticket and notify the recipient through their preferred channel. | Quick one-off transfer to a contact. |
| **Group storage** | Upload to a shared folder on a server owned by the group; authorised members can access. | Always-available group files. |
| **P2P replication** | Iroh shares content between peers; multiple participants keep copies. | Distributed backups, resilient sharing, no single server. |

A share can combine modes: replicate to peers who are online and keep a group
storage copy for offline members.

## Data model

| Field | Purpose |
| --- | --- |
| `contentHash` | Content-addressed identity of the file. |
| `metadata` | Name, size, type, timestamps; encrypted where practical. |
| `recipients` | Contacts or groups the share is addressed to. |
| `ticket` | Capability token for direct/Iroh sharing; expiry and revocation supported. |
| `mode` | direct / group-storage / p2p. |
| `pins` | List of participants promising to retain a copy. |
| `expiry` | Optional automatic revocation time. |

Content keys are wrapped to recipient or group keys from Contacts
([`contacts`](contacts)). Revocation expires tickets and re-wraps
keys for remaining recipients where feasible.

## Pinning and retention

- A user can **pin** a shared file to promise keeping a copy.
- The UI shows the number of independent copies currently available.
- Garbage collection respects pins: local cleanup never deletes a pinned file
  without an explicit user action.
- Group policy can set a target number of copies and per-member quotas.
- If a pinned file's holders drop below the target, the GUI asks whether to
  keep or re-replicate it.

Pinning turns group members' spare storage into a distributed backup mechanism,
as described in [`../contacts`](../contacts).

## Security properties

- All content is encrypted before leaving the device; servers and relays see
  ciphertext.
- Recipient-bound tickets: only intended contacts/groups can open a share.
- Tickets expire and can be revoked; revocation propagates to Iroh peers and
  group storage.
- No public, unlisted-link sharing by default; a link is tied to a capability.
- Metadata minimisation: group ids and public keys rather than display names
  on the wire.
- Reputation/abuse controls: quotas, rate limits, and admin removal of
  malicious content from group storage.
- Malware scanning is optional but offered before opening files from unknown
  contacts.

## User experience

1. Select file(s) in the file manager → **Share**.
2. Choose a contact or group from Contacts.
3. Pick a mode; direct share sets an expiry; group storage picks a folder; P2P
   sets pinning preference.
4. Recipient gets a notification through their configured channel
   ([`contacts`](contacts)).
5. Incoming shares appear in a dedicated view with sender identity and
   verification status.
6. "Shared with" pane shows recipients, copy count, expiry and revoke button.

Language follows [`user-experience`](user-experience): "Only
members of Friends can open this", with advanced details one click away.

## Offline and failure behaviour

- Shares created offline are queued and sent when a connection returns.
- Group storage unavailable → direct/P2P still works; the UI explains the
  degraded state.
- Peer unreachable → Iroh retries; ticket expiry is shown clearly.
- Lost local copy → re-download from any pinned peer or group storage.
- Storage pressure → user chooses what to unpin; the system never silently
  drops pinned data.

## Integration

| Component | Integration |
| --- | --- |
| Contacts | Recipient and group selection, identity verification, notifications. |
| DuckNet | Peer connectivity and group storage reachability. |
| App deployment | Apps may expose output streams/files as shares to their group. |
| SekkOS Settings | Storage quotas, pin defaults, retention policy. |

## Open items

Tracked in [`open-questions`](open-questions): large-file behaviour,
mobile peers, deduplication across groups, and whether to ship a default group
storage server package.
