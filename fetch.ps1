# Maintainer setup only; this script is never run by Cargo or by consumers.
param()
$ErrorActionPreference = "Stop"
$metadata = Get-Content -LiteralPath (Join-Path $PSScriptRoot "upstream.json") -Raw | ConvertFrom-Json
$library = Get-Content -LiteralPath (Join-Path $PSScriptRoot "src/lib.rs") -Raw
if (-not $library.Contains('pub const VERSION: &str = "' + $metadata.version + '";')) {
    throw "src/lib.rs VERSION does not match upstream.json"
}

function Test-Asset($path, $hash) {
    return (Test-Path -LiteralPath $path -PathType Leaf) -and
        ((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash -eq $hash)
}

$missing = @($metadata.files | Where-Object {
    -not (Test-Asset (Join-Path $PSScriptRoot $_.destination) $_.sha256)
})
if ($missing.Count -eq 0) {
    Write-Output "ConPTY $($metadata.version): cached assets verified"
    exit 0
}

$staging = Join-Path $PSScriptRoot ("target/fetch-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $staging -Force | Out-Null
$package = Join-Path $staging "conpty.zip"
Invoke-WebRequest -Uri $metadata.url -OutFile $package
$expanded = Join-Path $staging "expanded"
Expand-Archive -LiteralPath $package -DestinationPath $expanded

# Verify the entire pair before copying either file into the asset directory.
foreach ($file in $metadata.files) {
    $source = Join-Path $expanded $file.source
    if (-not (Test-Asset $source $file.sha256)) {
        throw "SHA-256 mismatch or missing upstream asset: $($file.source)"
    }
}
foreach ($file in $metadata.files) {
    $destination = Join-Path $PSScriptRoot $file.destination
    New-Item -ItemType Directory -Path (Split-Path -Parent $destination) -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $expanded $file.source) -Destination $destination
}
Write-Output "ConPTY $($metadata.version): downloaded assets verified"
