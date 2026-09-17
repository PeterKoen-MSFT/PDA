# Contributor Working Agreements

- **Project scope:** [README.md](README.md) describes the current application; [docs/DEMO.md](docs/DEMO.md) documents operation and limitations. Raise conflicting requirements before changing behavior.
- **Agent runtime:** use the published GitHub Copilot SDK pinned in the application. Keep the User view a simple Public-starting chat; Administrator and Compliance are separate pages.
- **Governance:** preserve monotonic confidentiality and execution protection, append-only business scope, policy version binding, model/tool authorization, pre-release checks, and signed decision evidence.
- **Truthful evidence:** distinguish live SDK execution from synthetic business results, demo-issued credentials, and simulated regional execution. Provider declarations are not independent attestations; the signed ledger is tamper-evident, not immutable storage.
- **Secrets and state:** keep dependencies, runtime state, signing material, credentials, recordings, and generated artifacts outside the repository. Never print secret values or read an operator's vault without authorization. See [SECURITY.md](SECURITY.md).
- **Validation:** run bounded checks scoped to the change. The existing suite uses `npm test` with external temporary state. Do not run live inference or provider calls without authorization.
- **Environment:** the demo requires Windows and serves loopback port 8110. Do not silently change ports, providers, or runtimes. No Docker or Hyper-V; use Podman only if containers are explicitly needed.
- **Desktop interface:** preserve the desktop-only layout. Browser validation must use an operator-approved external browser session without changing its dimensions or unrelated tabs.
- **Change discipline:** keep changes focused, reuse existing utilities and tests, and avoid unrequested helper scripts or broad refactors. Preserve licensing and user changes. Do not commit, rewrite history, push, or change repository visibility without explicit authorization.
