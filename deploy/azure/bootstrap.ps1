<#
.SYNOPSIS
    Provisions the Policy Driven Agent stack on a fresh Windows Server VM.

.DESCRIPTION
    Runs once, as SYSTEM, from the Azure custom script extension. It installs
    PowerShell 7, Node.js, Ollama and Caddy (all as machine-wide, PATH-registered
    tools), unpacks the unchanged application, installs the pinned SDK/DPAPI
    dependencies, writes a Caddy reverse-proxy configuration with basic auth and
    automatic HTTPS, opens the firewall, and registers the Caddy + demo services.

    The script is idempotent: re-running it (for example on a redeploy or update)
    skips tools that are already present, re-extracts the application, and
    re-registers the scheduled tasks.

    The application is NOT modified. It keeps listening on loopback 127.0.0.1:8110;
    Caddy is the only component that faces the public IP.
#>

[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '', Justification = 'Values arrive base64-encoded as custom script extension command-line arguments and are decoded locally.')]
param(
    [Parameter(Mandatory)] [string] $Fqdn,
    [Parameter(Mandatory)] [string] $BasicAuthUserB64,
    [Parameter(Mandatory)] [string] $BasicAuthPasswordB64,
    [Parameter(Mandatory)] [string] $AdminUsername,
    [Parameter(Mandatory)] [string] $AdminPasswordB64,
    [string] $OllamaModel = 'qwen2.5:7b',
    [string] $NodeVersion = '22.12.0',
    [string] $PwshVersion = '7.4.6'
)

$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Root       = 'C:\PDA'
$AppDir     = Join-Path $Root 'app'
$NodeDir    = Join-Path $Root 'node'
$OllamaDir  = Join-Path $Root 'ollama'
$CaddyDir   = Join-Path $Root 'caddy'
$PwshDir    = Join-Path $Root 'pwsh'
$DepsDir    = Join-Path $Root 'dependencies'
$ModelsDir  = Join-Path $Root 'ollama-models'
$GhDir      = Join-Path $Root 'gh'
$CaddyFile  = Join-Path $Root 'Caddyfile'
$LogDir     = Join-Path $Root 'logs'

foreach ($d in @($Root, $NodeDir, $OllamaDir, $CaddyDir, $PwshDir, $DepsDir, $ModelsDir, $GhDir, $LogDir)) {
    New-Item -ItemType Directory -Path $d -Force | Out-Null
}

Start-Transcript -Path (Join-Path $LogDir 'bootstrap.log') -Append | Out-Null

$BootstrapStart = Get-Date
Write-Host "[bootstrap] $($BootstrapStart.ToString('yyyy-MM-dd HH:mm:ss zzz')) Bootstrap started."

function Write-Step { param([string] $Message) Write-Host "[bootstrap] $((Get-Date).ToString('yyyy-MM-dd HH:mm:ss zzz')) $Message" }

function Add-MachinePath {
    param([string] $Directory)
    $current = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    if (($current -split ';') -notcontains $Directory) {
        [Environment]::SetEnvironmentVariable('Path', "$current;$Directory", 'Machine')
        Write-Step "Added to machine PATH: $Directory"
    }
    if (($env:Path -split ';') -notcontains $Directory) { $env:Path = "$env:Path;$Directory" }
}

function Get-DownloadedFile {
    # The extension drops fileUris into the current working directory.
    param([string] $Name)
    $candidate = Get-ChildItem -Path (Get-Location) -Filter $Name -File -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $candidate) {
        $candidate = Get-ChildItem -Path $PSScriptRoot -Filter $Name -File -ErrorAction SilentlyContinue | Select-Object -First 1
    }
    return $candidate
}

function Expand-ToDirectory {
    param([string] $ZipPath, [string] $Destination, [switch] $Flatten)
    $temp = Join-Path $env:TEMP ('extract-' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $temp -Force | Out-Null
    Expand-Archive -Path $ZipPath -DestinationPath $temp -Force
    $source = $temp
    if ($Flatten) {
        $entries = Get-ChildItem -Path $temp
        if ($entries.Count -eq 1 -and $entries[0].PSIsContainer) { $source = $entries[0].FullName }
    }
    Copy-Item -Path (Join-Path $source '*') -Destination $Destination -Recurse -Force
    Remove-Item -Path $temp -Recurse -Force -ErrorAction SilentlyContinue
}

$BasicAuthUser     = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($BasicAuthUserB64))
$BasicAuthPassword = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($BasicAuthPasswordB64))
$AdminPassword     = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($AdminPasswordB64))

# --- PowerShell 7 --------------------------------------------------------------
$pwshExe = Join-Path $PwshDir 'pwsh.exe'
if (-not (Test-Path $pwshExe)) {
    Write-Step "Installing PowerShell $PwshVersion"
    $zip = Join-Path $env:TEMP 'pwsh.zip'
    Invoke-WebRequest -Uri "https://github.com/PowerShell/PowerShell/releases/download/v$PwshVersion/PowerShell-$PwshVersion-win-x64.zip" -OutFile $zip
    Expand-ToDirectory -ZipPath $zip -Destination $PwshDir
    Remove-Item $zip -Force -ErrorAction SilentlyContinue
}
Add-MachinePath $PwshDir

# --- Node.js -------------------------------------------------------------------
$nodeExe = Join-Path $NodeDir 'node.exe'
$nodeCurrent = if (Test-Path $nodeExe) { (& $nodeExe --version).TrimStart('v') } else { '' }
if ($nodeCurrent -ne $NodeVersion) {
    Write-Step "Installing Node.js $NodeVersion (current: $(if ($nodeCurrent) { $nodeCurrent } else { 'none' }))"
    $zip = Join-Path $env:TEMP 'node.zip'
    Invoke-WebRequest -Uri "https://nodejs.org/dist/v$NodeVersion/node-v$NodeVersion-win-x64.zip" -OutFile $zip
    Expand-ToDirectory -ZipPath $zip -Destination $NodeDir -Flatten
    Remove-Item $zip -Force -ErrorAction SilentlyContinue
}
Add-MachinePath $NodeDir

# --- Ollama --------------------------------------------------------------------
$ollamaExe = Join-Path $OllamaDir 'ollama.exe'
if (-not (Test-Path $ollamaExe)) {
    Write-Step 'Installing Ollama'
    $zip = Join-Path $env:TEMP 'ollama.zip'
    Invoke-WebRequest -Uri 'https://github.com/ollama/ollama/releases/latest/download/ollama-windows-amd64.zip' -OutFile $zip
    Expand-ToDirectory -ZipPath $zip -Destination $OllamaDir -Flatten
    Remove-Item $zip -Force -ErrorAction SilentlyContinue
}
Add-MachinePath $OllamaDir
[Environment]::SetEnvironmentVariable('OLLAMA_MODELS', $ModelsDir, 'Machine')
$env:OLLAMA_MODELS = $ModelsDir

# --- Caddy ---------------------------------------------------------------------
$caddyExe = Join-Path $CaddyDir 'caddy.exe'
if (-not (Test-Path $caddyExe)) {
    Write-Step 'Installing Caddy'
    Invoke-WebRequest -Uri 'https://caddyserver.com/api/download?os=windows&arch=amd64' -OutFile $caddyExe
}
Add-MachinePath $CaddyDir

# --- Visual C++ runtime --------------------------------------------------------
# The Copilot SDK's native runtime (copilot-runtime.exe) links against the MSVC
# runtime; without it the SDK child process exits with 0xC0000135 (DLL not found).
if (-not (Test-Path (Join-Path $env:SystemRoot 'System32\vcruntime140_1.dll'))) {
    Write-Step 'Installing the Visual C++ redistributable'
    $vc = Join-Path $env:TEMP 'vc_redist.x64.exe'
    Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vc_redist.x64.exe' -OutFile $vc
    Start-Process -FilePath $vc -ArgumentList '/quiet', '/norestart' -Wait
    Remove-Item $vc -Force -ErrorAction SilentlyContinue
}

# --- GitHub CLI ----------------------------------------------------------------
# The Copilot SDK runtime authenticates the Copilot route via `gh auth token`, so gh
# must be on the machine PATH. The operator runs `gh auth login` once; the token then
# persists per-user and is read on every turn (works headless, across reboots).
$ghExe = Join-Path $GhDir 'bin\gh.exe'
if (-not (Test-Path $ghExe)) {
    Write-Step 'Installing the GitHub CLI'
    $rel = Invoke-RestMethod -Uri 'https://api.github.com/repos/cli/cli/releases/latest' -Headers @{ 'User-Agent' = 'pda-bootstrap' }
    $asset = $rel.assets | Where-Object { $_.name -like '*windows_amd64.zip' } | Select-Object -First 1
    if (-not $asset) { throw 'Could not resolve the gh windows_amd64.zip release asset.' }
    $zip = Join-Path $env:TEMP 'gh.zip'
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zip
    Expand-ToDirectory -ZipPath $zip -Destination $GhDir
    Remove-Item $zip -Force -ErrorAction SilentlyContinue
}
Add-MachinePath (Join-Path $GhDir 'bin')

# --- Application (unchanged) ---------------------------------------------------
Write-Step 'Unpacking the application'
$appZip = Get-DownloadedFile -Name 'app.zip'
if (-not $appZip) { throw 'app.zip was not delivered by the custom script extension.' }
if (Test-Path $AppDir) { Remove-Item -Path (Join-Path $AppDir '*') -Recurse -Force -ErrorAction SilentlyContinue }
New-Item -ItemType Directory -Path $AppDir -Force | Out-Null
Expand-Archive -Path $appZip.FullName -DestinationPath $AppDir -Force

# --- Pinned dependencies (SDK + DPAPI), resolved from a fixed machine path ------
Write-Step 'Installing pinned dependencies'
[Environment]::SetEnvironmentVariable('PDA_DEPENDENCIES', $DepsDir, 'Machine')
$env:PDA_DEPENDENCIES = $DepsDir
@'
{
  "name": "pda-dependencies",
  "private": true,
  "dependencies": {
    "@github/copilot-sdk": "1.0.13",
    "@primno/dpapi": "2.0.1"
  }
}
'@ | Set-Content -Path (Join-Path $DepsDir 'package.json') -Encoding utf8
# npm running as SYSTEM needs its global and cache folders to exist, else it fails ENOENT (-4058).
$npmCache = Join-Path $Root 'npm-cache'
New-Item -ItemType Directory -Path (Join-Path $env:APPDATA 'npm'), $npmCache -Force | Out-Null
Push-Location $DepsDir
try {
    & (Join-Path $NodeDir 'npm.cmd') install --no-audit --no-fund --cache $npmCache
    $npmExit = $LASTEXITCODE
} finally {
    Pop-Location
}
if ($npmExit -ne 0) { throw "npm install failed with exit code $npmExit" }

# --- GitHub Copilot CLI (provides the logged-in session the SDK reads for the Copilot route) ---
# Installed here; the interactive device-code sign-in (copilot -> /login) is done once by the operator.
Write-Step 'Installing the GitHub Copilot CLI'
& (Join-Path $NodeDir 'npm.cmd') install -g '@github/copilot' --no-audit --no-fund --cache $npmCache
if ($LASTEXITCODE -ne 0) { Write-Step "Copilot CLI install failed (exit $LASTEXITCODE); install it manually with 'npm install -g @github/copilot'." }

# --- Caddy configuration: basic auth + HTTPS + reverse proxy to the app ---------
Write-Step 'Writing Caddy configuration'
$hash = & $caddyExe hash-password --plaintext $BasicAuthPassword
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($hash)) { throw 'caddy hash-password failed.' }
$hash = $hash.Trim()
$caddyConfig = @"
{
	email admin@$Fqdn
}

$Fqdn {
	basic_auth {
		$BasicAuthUser $hash
	}
	# The app enforces a loopback Host/Origin; rewrite them so it accepts proxied requests unchanged.
	reverse_proxy 127.0.0.1:8110 {
		header_up Host 127.0.0.1:8110
		header_up Origin http://127.0.0.1:8110
	}
}
"@
Set-Content -Path $CaddyFile -Value $caddyConfig -Encoding utf8

# --- Windows firewall: allow the public HTTP/HTTPS ports -----------------------
foreach ($rule in @(@{ Name = 'PDA-HTTPS'; Port = 443 }, @{ Name = 'PDA-HTTP'; Port = 80 })) {
    if (-not (Get-NetFirewallRule -DisplayName $rule.Name -ErrorAction SilentlyContinue)) {
        New-NetFirewallRule -DisplayName $rule.Name -Direction Inbound -Action Allow -Protocol TCP -LocalPort $rule.Port | Out-Null
    }
}

# --- Pre-pull the Ollama model (non-fatal: falls back to first-use pull) --------
Write-Step "Pre-pulling Ollama model $OllamaModel"
$serve = $null
try {
    $serve = Start-Process -FilePath $ollamaExe -ArgumentList 'serve' -PassThru -WindowStyle Hidden
    $ready = $false
    for ($i = 0; $i -lt 30 -and -not $ready; $i++) {
        Start-Sleep -Seconds 2
        & $ollamaExe list *> $null
        if ($LASTEXITCODE -eq 0) { $ready = $true }
    }
    if (-not $ready) { throw 'Ollama server did not become ready in time.' }
    & $ollamaExe pull $OllamaModel
    if ($LASTEXITCODE -ne 0) { throw "ollama pull exited with code $LASTEXITCODE" }
    Write-Step "Model $OllamaModel is ready."
} catch {
    Write-Step "Model pre-pull skipped ($($_.Exception.Message)); pull it manually with 'ollama pull $OllamaModel'."
} finally {
    if ($serve -and -not $serve.HasExited) { Stop-Process -Id $serve.Id -Force -ErrorAction SilentlyContinue }
}

# --- Scheduled tasks -----------------------------------------------------------
# Caddy runs continuously as SYSTEM so the public HTTPS endpoint is always up.
Write-Step 'Registering the Caddy service task'
Unregister-ScheduledTask -TaskName 'PDA-Caddy' -Confirm:$false -ErrorAction SilentlyContinue
$caddyAction    = New-ScheduledTaskAction -Execute $caddyExe -Argument "run --config `"$CaddyFile`" --adapter caddyfile" -WorkingDirectory $CaddyDir
$caddyTrigger   = New-ScheduledTaskTrigger -AtStartup
$caddyPrincipal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType ServiceAccount -RunLevel Highest
$caddySettings  = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)
Register-ScheduledTask -TaskName 'PDA-Caddy' -Action $caddyAction -Trigger $caddyTrigger -Principal $caddyPrincipal -Settings $caddySettings | Out-Null
Start-ScheduledTask -TaskName 'PDA-Caddy'

# Auto-logon: the Copilot SDK's sign-in uses the Windows token broker (WAM/OneAuth),
# which is only retrievable from an interactive logon session. Auto-logon creates such
# a session automatically at every boot (no RDP), which fires the PDA-Demo AtLogon
# trigger. Sysinternals Autologon stores the password as an LSA secret, not as
# plaintext in the registry.
Write-Step 'Configuring auto-logon for the demo administrator'
$autologonExe = Join-Path $Root 'Autologon64.exe'
if (-not (Test-Path $autologonExe)) {
    $zip = Join-Path $env:TEMP 'Autologon.zip'
    Invoke-WebRequest -Uri 'https://download.sysinternals.com/files/AutoLogon.zip' -OutFile $zip
    Expand-Archive -Path $zip -DestinationPath $Root -Force
    Remove-Item $zip -Force -ErrorAction SilentlyContinue
}
& $autologonExe -accepteula $AdminUsername $env:COMPUTERNAME $AdminPassword | Out-Null
$autoLogon = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'AutoAdminLogon' -ErrorAction SilentlyContinue).AutoAdminLogon
if ($autoLogon -ne '1') { throw 'Auto-logon configuration failed (AutoAdminLogon is not 1).' }

# The demo (Ollama + Node) runs in the administrator's interactive session, started at
# logon. Auto-logon (above) creates that session automatically at every boot, so no RDP
# is required. An interactive session is mandatory: the Copilot SDK's WAM/OneAuth token
# cannot be read from a non-interactive (batch/service) logon.
Write-Step 'Registering the demo start task'
Unregister-ScheduledTask -TaskName 'PDA-Demo' -Confirm:$false -ErrorAction SilentlyContinue
$demoAction    = New-ScheduledTaskAction -Execute $pwshExe -Argument "-ExecutionPolicy Bypass -NoProfile -File `"$AppDir\startdemo.ps1`"" -WorkingDirectory $AppDir
$demoTrigger   = New-ScheduledTaskTrigger -AtLogOn -User $AdminUsername
$demoPrincipal = New-ScheduledTaskPrincipal -UserId $AdminUsername -LogonType Interactive -RunLevel Highest
$demoSettings  = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
Register-ScheduledTask -TaskName 'PDA-Demo' -Action $demoAction -Trigger $demoTrigger -Principal $demoPrincipal -Settings $demoSettings | Out-Null

Write-Step 'Bootstrap complete.'
$BootstrapEnd = Get-Date
$elapsed = $BootstrapEnd - $BootstrapStart
Write-Host ("[bootstrap] {0} Bootstrap finished. Started {1}, elapsed {2:hh\:mm\:ss} (hh:mm:ss)." -f `
    $BootstrapEnd.ToString('yyyy-MM-dd HH:mm:ss zzz'), `
    $BootstrapStart.ToString('yyyy-MM-dd HH:mm:ss zzz'), `
    $elapsed)
Stop-Transcript | Out-Null
