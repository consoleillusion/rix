# DuckNet

> **Status:** Design
> **Last updated:** 2026-11-18
> **See also:** [Contacts](09-contacts.md), [Threat model](03-threat-model.md), [../contacts.md](../contacts.md)

DuckNet is Rix's networking layer. It turns group membership into private,
encrypted connectivity using Netmaker to manage WireGuard meshes. Users manage
relationships in Contacts; the network configures itself.

## Goals

- Adding a contact to a group automatically provisions network membership.
- Each group can have its own address space and network policy.
- Traffic is end-to-end encrypted by WireGuard; the controller is not trusted
  with content.
- The control plane is user- or group-controlled, not operated by Rix.
- Peers stay connected when the controller is temporarily unavailable.

## Architecture

```
        Group (Contacts)
               │ membership
               ▼
     Netmaker controller (self-hosted)
               │ issues peer config / keys
               ▼
   WireGuard mesh (per group address space)
        │       │       │
      laptop  phone   shared service
               │
        relay fallback (optional)
```

Components:

| Component | Role |
| --- | --- |
| Netmaker controller | Managed by the user or group; stores network config and peer registry. |
| WireGuard peers | Every device and shared service in the group. |
| DNS / name resolution | Group-local names for services; no public DNS requirement. |
| Relay | Optional fallback when direct peer-to-peer is blocked by NAT. |
| Rix Settings / Contacts | User-facing control of networks and membership. |

## Control-plane trust

The controller is **self-hosted by default**, as agreed in the design. This is
a deliberate privacy decision: a Rix-operated controller would see the social
graph of every group.

Trust properties:

- The controller distributes peer configuration and membership state.
- It does **not** see file contents or application payloads; those are inside
  WireGuard and, for files, additionally Iroh-encrypted.
- Peer config is delivered over authenticated channels and validated by the
  client; a controller cannot silently redirect a peer to an arbitrary network
  without detection.
- Administrative actions on the controller are audited and visible to group
  admins.

See [`03-threat-model.md`](03-threat-model.md), scenarios 3 and 7.

## Setup experience

1. In Rix Settings → Network, choose "Create a network" or "Join a network".
2. Creating starts a self-hosted controller (local container or a server the
   group controls) with a guided setup wizard.
3. Joining uses an invitation containing the controller endpoint, network id
   and an authentication token; the group fingerprint is shown for
   verification.
4. Adding a contact to a group in Contacts automatically provisions their peer
   ([`09-contacts.md`](09-contacts.md)).
5. The GUI shows peers, address spaces, connection status and data usage.

No command-line Netmaker usage should be required in the normal path.

## Security policy

- One WireGuard key pair per device; per-device revocation through Contacts.
- Short-lived peer configuration with rotation; leaving a group revokes keys.
- Default-deny group firewall: peers reach only the services the group permits.
- Split tunnelling by default; an optional kill switch blocks traffic that
  would otherwise escape the mesh.
- No default route through the controller or relay.
- Relays see encrypted traffic only; they are untrusted.
- Network changes are signed and logged.

## Availability behaviour

- After a peer has joined, established WireGuard connections continue even if
  the controller goes offline.
- New peers cannot join while the controller is down; the GUI says so plainly.
- NAT traversal is attempted first; relays are used only when needed and are
  visible in the UI.
- IPv4 is the baseline; IPv6 support is desirable but not required for the
  first release.

## Integration

| Consumer | Use |
| --- | --- |
| Contacts | Source of membership and invitations. |
| File sharing | Direct peer connections and group storage reachability. |
| App deployment | Group-scoped service access; apps get network policy from their group. |
| Rix Settings | Network status, peer list, kill switch, relay settings. |

## Failure modes

| Failure | Response |
| --- | --- |
| Controller offline | Existing peers keep connectivity; joins queue. |
| NAT blocks direct links | Relay fallback, indicated in the UI. |
| IP conflict | Controller allocates from a per-group space; conflicts reported. |
| Compromised controller | Rotate network keys; signed config limits silent redirection. |
| Revoked member | WireGuard key removed and peer config rotated. |

## Open items

Tracked in [`15-open-questions.md`](15-open-questions.md): mobile/roaming
peers, IPv6, controller deployment packaging, and whether to support hosted
controllers as a clearly-labelled convenience option.
