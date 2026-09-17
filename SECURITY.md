# Security

## Supported Use

This repository is a local governance demonstration, not a production security boundary. Run it only on a trusted Windows workstation using synthetic data. The application listens on loopback port 8110. Do not expose it through a public listener, reverse proxy, or shared tunnel.

The User, Administrator, and Compliance pages are separate experiences, not enterprise identity or role-based access controls. Named regional execution can be simulated locally. Provider declarations and demo-issued participant credentials are not independent attestations. The signed ledger is tamper-evident, not immutable storage.

## Secrets and Data

- Keep application state and dependencies outside the repository. The default location is `%LOCALAPPDATA%/PDA/sdk-demo/`.
- Provider keys and private signing material are protected using Windows CurrentUser encryption. This does not protect against compromise of the signed-in workstation account.
- `settings/credentials.settings.json` defines fictional credential issuance and participants; it contains no issued credentials or private keys. `apiKeySecretName` values in model settings are lookup names, not API keys.
- Enter provider keys only through the local Administrator interface. Never put keys, access tokens, private certificates, real business data, or exported credentials in source, issues, screenshots, or recordings.
- Chats, ledger records, exports, and browser recordings can contain sensitive information even when their credentials are encrypted. Keep them private and outside Git.
- Git ignore rules help prevent accidental additions; they do not remove files already committed or prevent forced additions.

## Reporting a Vulnerability

Use GitHub private vulnerability reporting from the repository's Security tab when available. Do not file a public issue containing a working exploit, credentials, or private data. If private reporting is unavailable, ask the maintainer for a private reporting channel without including sensitive details.

If a credential may have been exposed, revoke or rotate it at its issuer before cleaning the repository. Removing a file or rewriting history does not invalidate a credential or erase copies already downloaded.

## Publication Review

Before publishing or changing visibility:

1. Review the exact source snapshot, tracked files, and ignored artifacts. Keep recordings, personal feedback, runtime state, and generated evidence out of the release.
2. Scan both the working tree and all intended Git refs with an up-to-date secret scanner. Review binaries and images separately; a clean text scan is not proof that no secret exists.
3. Review commit messages and author identities, branches, tags, Git LFS objects, releases, Actions logs and artifacts, issues, pull requests, wiki content, and attachments. Local file deletion does not remove these copies.
4. Resolve unwanted history before publication, using an explicitly approved history rewrite or a new repository containing a clean snapshot. Coordinate remote cleanup and cached-reference removal where necessary.
5. Enable GitHub private vulnerability reporting, secret scanning, and push protection where available. Verify the repository's actual visibility instead of assuming it is private.

Repository sanitation reduces accidental disclosure risk. It does not constitute a penetration test, production hardening, or a guarantee against disclosure.
