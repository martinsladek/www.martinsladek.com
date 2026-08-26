# All host/user/key values come from gitignored deploy-config.ps1.
# Never prints the PPK path. Never deletes remote files.

$ErrorActionPreference = "Stop"

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..\..")).Path
$ConfigPath = Join-Path $RepoRoot ".cursor\deploy-config.ps1"

function Find-Pscp {
    $cmd = Get-Command pscp.exe -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    foreach ($p in @(
            (Join-Path $env:ProgramFiles "PuTTY\pscp.exe"),
            (Join-Path ${env:ProgramFiles(x86)} "PuTTY\pscp.exe")
        )) {
        if ($p -and (Test-Path -LiteralPath $p)) { return $p }
    }
    throw "pscp.exe not found. Install PuTTY and add it to PATH."
}

function Import-DeployConfig {
    if (-not (Test-Path -LiteralPath $ConfigPath)) {
        Write-Error "Missing .cursor/deploy-config.ps1. In Cursor run /deploy so the agent can fill it from a PuTTY session, or copy deploy-config.ps1.example."
        exit 2
    }
    $RepoUrl = $null
    $RemoteSpec = $null
    $WorkRoot = $null
    $DeployPpk = $null
    . $ConfigPath
    if (-not [string]::IsNullOrWhiteSpace($env:DEPLOY_WWW_PPK)) {
        $DeployPpk = $env:DEPLOY_WWW_PPK
    }
    foreach ($name in @("RepoUrl", "RemoteSpec", "WorkRoot", "DeployPpk")) {
        $v = Get-Variable -Name $name -ValueOnly -ErrorAction SilentlyContinue
        if ([string]::IsNullOrWhiteSpace($v)) {
            Write-Error "deploy-config.ps1 is missing `$$name."
            exit 2
        }
    }
    return [pscustomobject]@{
        RepoUrl    = $RepoUrl
        RemoteSpec = $RemoteSpec
        WorkRoot   = $WorkRoot
        DeployPpk  = $DeployPpk
    }
}

$cfg = Import-DeployConfig
if (-not (Test-Path -LiteralPath $cfg.DeployPpk)) {
    Write-Error "Configured PPK path does not exist."
    exit 2
}

$RepoDir = Join-Path $cfg.WorkRoot "repo"
$StageDir = Join-Path $cfg.WorkRoot "stage"
New-Item -ItemType Directory -Force -Path $cfg.WorkRoot | Out-Null

if (Test-Path -LiteralPath (Join-Path $RepoDir ".git")) {
    git -C $RepoDir fetch --depth 1 origin main
    if ($LASTEXITCODE -ne 0) { throw "git fetch failed" }
    git -C $RepoDir checkout -B main origin/main
    if ($LASTEXITCODE -ne 0) { throw "git checkout origin/main failed" }
}
else {
    if (Test-Path -LiteralPath $RepoDir) {
        Remove-Item -LiteralPath $RepoDir -Recurse -Force
    }
    git clone --depth 1 --branch main $cfg.RepoUrl $RepoDir
    if ($LASTEXITCODE -ne 0) { throw "git clone failed" }
}

if (Test-Path -LiteralPath $StageDir) {
    Remove-Item -LiteralPath $StageDir -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $StageDir | Out-Null

robocopy $RepoDir $StageDir /E /NFL /NDL /NJH /NJS /NC /NS /XD .git | Out-Null
if ($LASTEXITCODE -ge 8) { throw "robocopy staging failed ($LASTEXITCODE)" }

Get-ChildItem -LiteralPath $StageDir -Force | Where-Object {
    $_.Name.StartsWith(".") -and $_.Name -ne ".htaccess" -and $_.Name -ne "." -and $_.Name -ne ".."
} | ForEach-Object {
    Remove-Item -LiteralPath $_.FullName -Recurse -Force
}

$pscp = Find-Pscp
$items = @(Get-ChildItem -LiteralPath $StageDir -Force)
if ($items.Count -eq 0) { throw "staging tree is empty" }

foreach ($item in $items) {
    $dest = $cfg.RemoteSpec.TrimEnd("/") + "/" + $item.Name
    & $pscp -batch -r -i $cfg.DeployPpk $item.FullName $dest
    if ($LASTEXITCODE -ne 0) {
        throw "pscp failed for $($item.Name) (exit $LASTEXITCODE)"
    }
}

Write-Output "Uploaded origin/main to the web host (overwrite only, remote extras kept)."
exit 0
