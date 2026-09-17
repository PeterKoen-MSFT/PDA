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
$CaddyFile  = Join-Path $Root 'Caddyfile'
$LogDir     = Join-Path $Root 'logs'

foreach ($d in @($Root, $NodeDir, $OllamaDir, $CaddyDir, $PwshDir, $DepsDir, $ModelsDir, $LogDir)) {
    New-Item -ItemType Directory -Path $d -Force | Out-Null
}

Start-Transcript -Path (Join-Path $LogDir 'bootstrap.log') -Append | Out-Null

function Write-Step { param([string] $Message) Write-Host "[bootstrap] $Message" }

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

# The demo (Ollama + Node) runs in the administrator's security context at boot,
# with no interactive logon and no RDP required, so the machine recovers by itself
# after a restart. A batch (password) logon still loads the administrator profile,
# so DPAPI CurrentUser secrets and the cached Copilot sign-in continue to work.
# The task action keeps running while the app listens on 8110; that keeps the batch
# logon session (and therefore the node process) alive, and lets Task Scheduler
# restart the whole stack if it ever exits.
Write-Step 'Registering the demo start task'
Unregister-ScheduledTask -TaskName 'PDA-Demo' -Confirm:$false -ErrorAction SilentlyContinue
$demoSupervisor = "& '$AppDir\startdemo.ps1'; for (`$i = 0; `$i -lt 24 -and -not (Get-NetTCPConnection -LocalPort 8110 -State Listen -ErrorAction SilentlyContinue); `$i++) { Start-Sleep -Seconds 5 }; while (Get-NetTCPConnection -LocalPort 8110 -State Listen -ErrorAction SilentlyContinue) { Start-Sleep -Seconds 30 }"
$demoAction    = New-ScheduledTaskAction -Execute $pwshExe -Argument "-ExecutionPolicy Bypass -NoProfile -Command `"$demoSupervisor`"" -WorkingDirectory $AppDir
$demoTrigger   = New-ScheduledTaskTrigger -AtStartup
$demoSettings  = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1) -ExecutionTimeLimit ([TimeSpan]::Zero) -MultipleInstances IgnoreNew
# -User/-Password (batch logon) and -Principal are mutually exclusive parameter sets; pass RunLevel here.
Register-ScheduledTask -TaskName 'PDA-Demo' -Action $demoAction -Trigger $demoTrigger -Settings $demoSettings -User $AdminUsername -Password $AdminPassword -RunLevel Highest | Out-Null
Start-ScheduledTask -TaskName 'PDA-Demo'

Write-Step 'Bootstrap complete.'
Stop-Transcript | Out-Null
