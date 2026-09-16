# Azure VM deployment

This is an **optional** way to run the Policy Driven Agent demo on a single Azure
Windows VM, reachable over a public HTTPS address with basic authentication. It is
completely separate from the local [`startdemo.ps1`](../../startdemo.ps1) option —
both produce the same running system, one on your workstation and one in Azure.

The application is **not modified**. It keeps listening on loopback
`127.0.0.1:8110`. On the VM, [Caddy](https://caddyserver.com/) terminates HTTPS,
enforces basic auth, and reverse-proxies to the app. The GitHub Copilot SDK,
Ollama, Mistral, the `settings/` files and the DPAPI-protected state all behave
exactly as they do on-premises.

## What gets created

Everything is provisioned with **Bicep Azure Verified Modules** into one resource
group in **Sweden Central**. The resource group and every resource are tagged
`SecurityControl: Ignore`.

| Resource | Module | Notes |
| --- | --- | --- |
| Resource group | (created by the script) | Created if it does not exist. |
| Staging storage | `avm/res/storage/storage-account` | Hands the bootstrap + app package to the VM, then is deleted with the group. |
| Network security group | `avm/res/network/network-security-group` | Allows inbound 443, 80 (HTTPS cert), 3389 (RDP). |
| Virtual network | `avm/res/network/virtual-network` | Single subnet. |
| Windows VM + public IP | `avm/res/compute/virtual-machine` | `Standard_E8s_v5` (8 vCPU, 64 GiB RAM, no GPU), Windows Server 2025. |

The VM's custom script extension installs PowerShell 7, Node.js, Ollama and Caddy,
unpacks the application, installs the pinned `@github/copilot-sdk@1.0.13` and
`@primno/dpapi@2.0.1` dependencies, writes the Caddy configuration, and registers
two scheduled tasks:

- **PDA-Caddy** — runs as SYSTEM at startup, so the public HTTPS endpoint is always up.
- **PDA-Demo** — runs `startdemo.ps1` in the administrator's session at logon, so
  the demo starts (as the same user each time, keeping DPAPI secrets consistent)
  and Copilot sign-in can be completed over RDP, just like on-premises.

## Prerequisites

- PowerShell with the Az modules: `Install-Module Az -Scope CurrentUser`
- `Connect-AzAccount` with rights to create the resource group and resources
- A basic-auth password with no `"` characters in the config file

## Configure

Copy the example config and edit it. The real config holds the basic-auth
credentials and is git-ignored.

```powershell
cd deploy/azure
Copy-Item pda-vm.config.example.json pda-vm.config.json
# edit pda-vm.config.json: set basicAuthPassword (and, if you like, other values)
```

The VM administrator password is **not** stored in the file — the deploy script
prompts for it securely (or accept it via `-AdminPassword`).

## Start (deploy)

```powershell
cd deploy/azure
./Deploy-AzureVM.ps1
```

The script is **idempotent** — run it as often as you like. It ensures the
resource group and tag, derives deterministic resource names, and deploys in
incremental mode, so repeated runs converge to the same system instead of creating
duplicates. When it finishes it prints the public URL, the RDP host, and the
basic-auth user.

First run: RDP to the printed host as the VM administrator. The demo starts
automatically at logon. Open the **Administrator** page to enter the Mistral key
and sign in to Copilot, exactly as on-premises. Certificate issuance for the
public name takes about a minute; until then the browser may show a TLS warning.

Then browse to:

- **User:** `https://<public-name>/`
- **Administrator:** `https://<public-name>/admin`
- **Compliance:** `https://<public-name>/compliance`

…and sign in with the basic-auth user and password from your config file. Chat,
Administrator, Compliance and the guided demo stories work unchanged.

## Update

Re-run the deploy script. It repackages the current working tree, uploads it, and
the VM re-extracts the application and restarts the services:

```powershell
./Deploy-AzureVM.ps1
```

To apply an update immediately without waiting for the next logon, RDP in and
either sign out/in or run `C:\PDA\app\startdemo.ps1`.

## Remove

Deletes the resource group and everything in it (VM, disk, network, public IP,
staging storage). It does not touch the local deployment.

```powershell
./Remove-AzureVM.ps1          # prompts for confirmation
./Remove-AzureVM.ps1 -Force   # no prompt
```

## Notes and limits

- The VM is Windows because the app uses Windows DPAPI (`@primno/dpapi`) for its
  protected state. DPAPI state is per-user; a fresh VM starts with fresh state and
  you enter secrets (e.g. the Mistral key) once via the Administrator page.
- Basic auth is the only gate on the public endpoint, as requested. Restrict
  `allowedSourceAddressPrefix` in the config to your IP/CIDR if you want to limit
  who can reach it.
- Ollama runs on CPU (no GPU). A full story can take several minutes, the same as
  on the local CPU workstation.
- The local `startdemo.ps1` / `stopdemo.ps1` flow is unchanged and independent.
