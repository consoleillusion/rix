# DuckPAM – Password-based authentication with post-quantum cryptographic key management

DuckPAM is a Linux PAM (Pluggable Authentication Module) that combines traditional password authentication with post-quantum cryptography.

It provides a way to associate a user's password with a cryptographic identity, allowing applications and external services to obtain cryptographic secrets as part of the login process.

Rather than simply checking whether a password is correct, DuckPAM uses the password to unlock an encrypted NTRU private key.

## What DuckPAM offers

### 1\. Password-protected cryptographic identities

DuckPAM generates an NTRU public/private keypair for a user.

- The public key can be shared with external services.
- The private key is encrypted using AES-256-GCM.
- Argon2 derives the encryption key from the user's password.
- The encrypted keypair is stored in `/etc/duckshadow`.

This gives users a cryptographic identity that is unlocked by their login password.

### 2\. Post-quantum key encapsulation

DuckPAM uses NTRU-HPS-2048-509, a post-quantum key encapsulation mechanism.

This allows external parties to use a user's public key to encapsulate a shared secret.

When the user logs in, DuckPAM can use the unlocked private key to recover that secret.

This provides a mechanism for establishing shared cryptographic secrets without directly exchanging passwords or private keys.

### 3\. Integration with Linux authentication

DuckPAM integrates directly with PAM, allowing it to participate in the Linux authentication process.

During login, it:

- Requests the user's password.
- Unlocks the corresponding NTRU private key.
- Makes the associated public key available through the `PUBLIC_KEY` PAM environment variable.
- Executes configured duckling commands.

This connects Linux login authentication with cryptographic identity management.

### 4\. Programmable secret distribution (Ducklings)

One of DuckPAM's more distinctive features is its ducklings system.

Ducklings are configurable command pairs defined in:

`/etc/ducklings`

Each entry consists of:

- A command that produces an NTRU ciphertext.
- A command that receives the resulting shared secret.

The format is:

text

```text
ciphertext_command => target_command
```

When authentication succeeds, DuckPAM:

1. Executes the ciphertext-producing command.
2. Reads its Base64-encoded NTRU ciphertext.
3. Uses the user's private key to decapsulate it.
4. Sends the resulting shared secret to the target command through stdin.
5. Prints the target command's output.

This makes it possible to integrate DuckPAM with external applications and services that need access to user-specific cryptographic secrets.

For example, this mechanism could be used to:

- Unlock encrypted resources during login.
- Retrieve application-specific secrets.
- Establish shared secrets with remote services.
- Integrate cryptographic authentication into custom scripts.

### 5\. Password management

DuckPAM also provides password-change functionality through PAM.

When a user changes their password, DuckPAM:

- Unlocks their existing private key using the current password.
- Derives a new encryption key from the new password.
- Re-encrypts the existing private key.
- Updates `/etc/duckshadow`.

The user's underlying cryptographic identity remains the same when their password changes.

## Technologies and components

| Component | Technology |
| --- | --- |
| Authentication integration | Linux PAM |
| Programming language | Rust |
| Post-quantum cryptography | NTRU-HPS-2048-509 |
| Password-based key derivation | Argon2 |
| Symmetric encryption | AES-256-GCM |
| Key storage | `/etc/duckshadow` |
| Command integration | `/etc/ducklings` |

## Example use case

Imagine a Linux user who needs access to several encrypted resources when logging into their workstation.

With DuckPAM:

1. The user logs into Linux with their password.
2. DuckPAM unlocks their NTRU private key.
3. Configured ducklings request ciphertexts from external services.
4. DuckPAM decapsulates those ciphertexts.
5. The resulting shared secrets are passed to the appropriate applications.
6. Those applications can use the secrets to unlock their respective resources.

The user only needs to authenticate once, while multiple applications can obtain their own cryptographic secrets through the login process.

---

## In summary

DuckPAM offers three main capabilities:

- **Cryptographic identity management:** Associates user passwords with encrypted post-quantum NTRU keypairs.
- **PAM integration:** Makes cryptographic identities available during Linux authentication.
- **Programmable secret distribution:** Uses the ducklings mechanism to obtain and deliver shared secrets to external programs.

Its central idea is to make **logging into Linux a starting point for unlocking cryptographic identities and provisioning secrets to other applications and services.**

Rather than being just another password-authentication module, DuckPAM connects operating-system authentication with post-quantum cryptography and application-level secret management.
