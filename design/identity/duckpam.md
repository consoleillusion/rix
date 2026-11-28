# DuckPAM

> **Status:** Design
> **Last updated:** 2026-11-18
> **See also:** [Threat model](../system-design/threat-model.md), [Contacts](contacts.md), [Security defaults](../system-design/security-defaults.md), [Research notes](../reference/duckpam-research.md)

DuckPAM is SekkOS's authentication and identity layer. It turns a password into a
post-quantum cryptographic identity at login, and uses that identity to deliver
application secrets without asking the user to manage keys by hand.

The raw research notes are in [`duckpam-research`](../reference/duckpam-research.md); this document is
the implementation design. No DuckPAM code exists in the repository yet.

## Purpose

1. Give every user a cryptographic identity unlocked by the password they
   already use to log in.
2. Make that identity post-quantum (NTRU-HPS-2048-509).
3. Provide a programmable way to deliver per-application secrets at login
   (ducklings), so apps do not store long-lived credentials.
4. Keep the identity stable across password changes.

## Cryptographic building blocks

| Purpose | Mechanism |
| --- | --- |
| Key encapsulation | NTRU-HPS-2048-509 (post-quantum KEM) |
| Private-key encryption | AES-256-GCM |
| Password-based key derivation | Argon2 |
| Encrypted key store | `/etc/duckshadow` |
| Command configuration | `/etc/ducklings` |
| PAM exposure | `PUBLIC_KEY` environment variable during session |

## Identity hierarchy

The DuckPAM keypair is the **root identity** for the user, as agreed in the
design. Everything else derives from it:

```
                    password + Argon2
                           │
                    /etc/duckshadow (encrypted NTRU private key)
                           │
                    Root identity (public key = user identifier)
                           │
        ┌──────────────────┼───────────────────┐
        ▼                  ▼                   ▼
  Per-service keys    Per-device keys     Group key unwrapping
  (HKDF, scoped)      (root + device      (group keys wrapped to
                       salt)               member public keys)
        │
        ▼
  Duckling secrets delivered to apps at login
```

Rules:

- The root private key never leaves the login process.
- Derived keys are domain-separated; a leak in one service does not reveal
  another.
- Per-device keys allow revoking a lost device without rotating the identity.
- Group keys are distributed by wrapping to member public keys
  ([`contacts`](contacts.md)).

## Login flow

1. PAM requests the user's password.
2. DuckPAM reads `/etc/duckshadow`, derives the AES key with Argon2 and
   decrypts the NTRU private key.
3. The public key is exported as `PUBLIC_KEY` in the PAM environment for the
   session.
4. Configured ducklings run: each produces a Base64 NTRU ciphertext.
5. DuckPAM decapsulates each ciphertext with the private key and writes the
   shared secret to the target command's stdin.
6. Private key material is cleared from memory where the runtime permits.
7. A session audit entry records that authentication and secret delivery
   occurred (never the secret itself).

Failed authentication is rate-limited and logged without revealing whether the
user exists or which part failed.

## Password changes

Changing the password must **not** change the user's identity:

1. Unlock the existing private key with the current password.
2. Derive a new AES key from the new password.
3. Re-encrypt the same private key and update `/etc/duckshadow`.
4. Re-derive any password-dependent material; keep the public key unchanged.

This preserves all group memberships, shares and derived key relationships.

## Ducklings: programmable secret distribution

`/etc/ducklings` contains lines of the form:

```text
ciphertext_command => target_command
```

At successful authentication DuckPAM runs the ciphertext command, decapsulates
its Base64 output and pipes the secret to the target command.

Safety rules for the implementation:

- Only commands installed by root in trusted paths may be configured; user-
  writable paths are rejected.
- Commands run with a minimal environment, no shell interpretation, strict
  timeouts and resource limits.
- Secrets never appear in process listings, logs, crash dumps or GUI history.
- Each duckling is scoped to one app/service identity; no shared "all secrets"
  command.
- Failures are reported generically to the user and in detail only to an
  admin audit log.
- The GUI shows configured ducklings and allows revocation.

Example use cases: unlocking encrypted mounts, retrieving app-specific
tokens, establishing shared secrets with remote services. These are described
in [`duckpam-research`](../reference/duckpam-research.md).

## Recovery (agreed design)

The user configures this at first login; the default is recovery codes.

### Default: recovery codes

- Generate a set of single-use, high-entropy codes at first login.
- Store hashes of the codes, not the codes themselves.
- Display them once in the wizard with a prompt to print or write them down.
- Using a code restores access to the encrypted key store and immediately
  invalidates that code; the GUI offers to regenerate the remaining set.

### Opt-in: trusted contacts

- Threshold (Shamir-style) split of a recovery secret across a configurable
  number of trusted contacts from Contacts groups.
- A quorum can reconstruct the secret; fewer than the threshold learn nothing.
- Every recovery attempt requires explicit approval from the required
  contacts and is visible in the user's audit log.
- Enabling this is a deliberate choice: it involves other people and exposes
  that they are part of the user's recovery set.

SekkOS operates **no escrow**. If both options are lost, the identity and data it
protects are unrecoverable; the installer and wizard must state this clearly.

## Security considerations

- **PAM attack surface.** Keep the module small; no network calls during
  authentication; fuzz the parser for `/etc/duckshadow` and `/etc/ducklings`.
- **Key material in memory.** Minimise lifetime, lock pages where possible,
  and avoid swapping for the authentication process.
- **Rate limiting.** Throttle failed attempts at the PAM layer; cooperate with
  the display manager lockout.
- **Audit.** Log identity, time, source and outcome; never log secrets or
  ciphertext plaintext.
- **Hardware roots (future).** TPM2 or a hardware security key may wrap the
  encrypted key store, but must not replace the recovery key.

## Integration points

| Component | Integration |
| --- | --- |
| Display manager / PAM | Stack DuckPAM with system authentication. |
| SekkOS Settings | Identity fingerprint, duckling management, recovery configuration. |
| Contacts | Public-key identity, verification, trusted-contacts recovery. |
| App deployment | Per-app secrets injected at start; no credentials in app images. |
| Auditing | Login and recovery events visible to the user and group admins. |

## Open items

Tracked in [`open-questions`](../operations/open-questions.md): exact KEM library
choice and audit, hardware-token wrapping, rotation of a compromised root key,
and cross-device identity sync details.
