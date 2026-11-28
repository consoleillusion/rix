# Notifications and communications

> **Status:** Design
> **Last updated:** 2026-11-28
> **See also:** [Contacts](../identity/contacts.md), [File sharing](file-sharing.md), [User experience](../experience/user-experience.md), [Vision notes](../reference/contacts-vision.md)

Notifications are how SekkOS tells people about relationship-driven events:
a new share, an invitation, a group change, an update or a security notice.
They are the delivery layer for the relationships defined in
[Contacts](../identity/contacts.md), not a separate chat service.

## Goals

- Deliver the event a user needs, through the channel they already use.
- Never require a SekkOS-operated push service or account.
- Put only a capability or short summary in the notification, never file
  contents, secrets or the social graph.
- Work offline: queue events locally and deliver them when a connection returns.
- Make every notification actionable in the SekkOS app, in plain language.

## Delivery channels

| Channel | Role | Default? |
| --- | --- | --- |
| In-app notifications | Local notification centre, always available even offline. | Yes |
| External bridges | User-configured apps such as Telegram, SMS or email for a contact. | Per contact |
| Group service notices | Group-owned services may post status and audit events to the group. | Opt-in |

A contact's `preferredChannel` in Contacts selects the default for events
addressed to that person. Every channel is configured by the user or group;
SekkOS does not proxy message content through infrastructure it operates.
External bridge providers see routing metadata (that a message was sent to an
address), so the message body stays minimal.

## Event model

| Event | Source | Recipients | Notification |
| --- | --- | --- | --- |
| Share created | [File sharing](file-sharing.md) | Contact or group | Sender, file name, expiry, open action. |
| Invitation | [Contacts](../identity/contacts.md) | Invitee | Group fingerprint and accept/decline action. |
| Membership change | Contacts group admins | Group members | Who changed, visible in the audit view. |
| Peer or service status | [DuckNet](ducknet.md), [App deployment](app-deployment.md) | Group members | Short status, no internal addresses. |
| Update ready or rolled back | [Stability and updates](../system-design/stability-and-updates.md) | Device owner | Plain-language status and reboot/rollback action. |
| Recovery or security notice | [DuckPAM](../identity/duckpam.md) | Device owner | What happened and what to check; no codes or secrets. |

Events carry a stable id, source, timestamp, recipient identity, a short summary
and an optional capability ticket. Tickets are the same scoped, expiring tokens
used by file sharing; they are never guessable links or public URLs.

## Privacy and trust

- Notification payloads contain a summary and a ticket, not file contents,
  keys, locations or device identifiers.
- Wire identifiers are public keys and opaque group ids; display names are
  resolved locally.
- An external bridge is treated as an untrusted transport: a compromised
  provider can see that a notification was delivered, but cannot open the share
  without the recipient's key.
- Group admins can see audit events for membership and policy changes; they
  cannot read private messages between members.
- Users can mute, digest or disable each event type without losing the event
  from the local audit view.

## Offline and failure behaviour

- Events created offline are queued locally with their expiry.
- If a bridge is unavailable, the in-app notification is shown and delivery is
  retried with backoff; duplicate events are collapsed by id.
- An expired ticket is shown as expired rather than silently dropped.
- A user changing a contact's channel keeps the history but new events use the
  new channel.
- No notification is retried forever; failures are visible in the notification
  centre with a "retry" action.

## User experience

Notifications follow [User experience](../experience/user-experience.md): "Kim
shared photos with Friends" with an **Open** button, not a capability string or
a raw event id. Advanced details (sender fingerprint, channel, delivery status)
are one click away. The settings screen shows per-contact channels and
per-event-type defaults, using the same typed settings model as the rest of
SekkOS Settings.

## Integration

| Component | Integration |
| --- | --- |
| Contacts | Recipients, preferred channels, invitations, verification status. |
| File sharing | Share tickets and expiry shown in notifications. |
| DuckNet / App deployment | Peer, service and group status events. |
| Stability and updates | Update-ready, applied and rollback notices. |
| DuckPAM | Login, recovery and audit notices without secrets. |

## Open items

Tracked in [open questions](../operations/open-questions.md): how external bridges are
packaged and trusted, and whether to define a standard event schema for group
services.
