# Writes gitignored .cursor/deploy-config.ps1 from a PuTTY session.
# Does not print the PPK path.

param(
    [Parameter(Mandatory = $true)]
    [string]$SessionName
)

$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..\..")).Path
$OutFile = Join-Path $RepoRoot ".cursor\deploy-config.ps1"
$base = "HKCU:\Software\SimonTatham\PuTTY\Sessions"

$match = $null
foreach ($key in Get-ChildItem -LiteralPath $base) {
    $name = [Uri]::UnescapeDataString($key.PSChildName)
    if ($name -eq $SessionName) { $match = $key; break }
}
if (-not $match) { throw "PuTTY session not found: $SessionName" }

$props = Get-ItemProperty -LiteralPath $match.PSPath
$user = [string]$props.UserName
$hostName = [string]$props.HostName
$ppk = [string]$props.PublicKeyFile
if ([string]::IsNullOrWhiteSpace($user) -or [string]::IsNullOrWhiteSpace($hostName)) {
    throw "PuTTY session is missing UserName or HostName."
}
if ([string]::IsNullOrWhiteSpace($ppk) -or -not (Test-Path -LiteralPath $ppk)) {
    throw "PuTTY session has no usable PublicKeyFile (.ppk)."
}

$remotePath = "/home/$user/www/www.martinsladek.com"
$remoteSpec = "${user}@${hostName}:${remotePath}"
$workRoot = Join-Path $env:LOCALAPPDATA "www.martinsladek.com\www-deploy"
$repoUrl = "https://github.com/martinsladek/www.martinsladek.com.git"
$ppkEsc = $ppk.Replace("'", "''")

@(
    "# Generated from PuTTY session. Gitignored. Do not commit."
    "`$RepoUrl = '$repoUrl'"
    "`$RemoteSpec = '$remoteSpec'"
    "`$WorkRoot = Join-Path `$env:LOCALAPPDATA 'www.martinsladek.com\www-deploy'"
    "`$DeployPpk = '$ppkEsc'"
) | Set-Content -LiteralPath $OutFile -Encoding UTF8

Write-Output "Wrote deploy-config.ps1 from PuTTY session '$SessionName'."
Write-Output "RemoteSpec=$remoteSpec"
Write-Output "WorkRoot=$workRoot"
Write-Output "PPK path stored locally (not printed)."
