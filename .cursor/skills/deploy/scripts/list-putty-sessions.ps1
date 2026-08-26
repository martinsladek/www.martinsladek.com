# Lists PuTTY saved sessions. Prints JSON: name, user, host, hasPpk.
# Does not print the PPK filesystem path.

$ErrorActionPreference = "Stop"
$base = "HKCU:\Software\SimonTatham\PuTTY\Sessions"
if (-not (Test-Path -LiteralPath $base)) {
    "[]"
    exit 0
}

$rows = @(foreach ($key in Get-ChildItem -LiteralPath $base) {
    $enc = $key.PSChildName
    $name = [Uri]::UnescapeDataString($enc)
    $user = (Get-ItemProperty -LiteralPath $key.PSPath -Name UserName -ErrorAction SilentlyContinue).UserName
    $hostName = (Get-ItemProperty -LiteralPath $key.PSPath -Name HostName -ErrorAction SilentlyContinue).HostName
    $ppk = (Get-ItemProperty -LiteralPath $key.PSPath -Name PublicKeyFile -ErrorAction SilentlyContinue).PublicKeyFile
    [pscustomobject]@{
        name   = $name
        user   = [string]$user
        host   = [string]$hostName
        hasPpk = -not [string]::IsNullOrWhiteSpace($ppk)
    }
})

ConvertTo-Json -InputObject @($rows) -Compress
