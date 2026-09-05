#!/usr/bin/env pwsh

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Version,
    [Parameter(Position = 1)]
    [string]$Destination = "Alpaka-Modpack.mrpack",
    [Parameter(Position = 2)]
    [string]$SourceDir = "src"
)

if (-not (Test-Path $SourceDir)) {
    Write-Error "Source directory '$SourceDir' not found."
    exit 1
}

# Update version in modrinth.index.json if provided
if ($Version) {
    $indexPath = Join-Path $SourceDir "modrinth.index.json"
    if (Test-Path $indexPath) {
        Write-Output "Updating modrinth.index.json versionId to: $Version"
        $json = Get-Content $indexPath -Raw | ConvertFrom-Json
        $json.versionId = $Version
        $json | ConvertTo-Json -Depth 100 | Set-Content $indexPath -Encoding UTF8
    }
}

if (Test-Path $Destination) {
    Remove-Item $Destination -Force
}

Add-Type -AssemblyName System.IO.Compression.FileSystem

$base = (Get-Item $SourceDir).FullName
if (-not $base.EndsWith([System.IO.Path]::DirectorySeparatorChar)) { 
    $base += [System.IO.Path]::DirectorySeparatorChar 
}

# Exclude paths containing ".git" or "node_modules", and files named ".editorconfig" or build scripts
$files = Get-ChildItem -Path $SourceDir -Recurse -File -Force | Where-Object {
    $p = $_.FullName
    if ($p -match "\\.git") { return $false }
    if ($p -match "\\\\node_modules\\\\") { return $false }
    if ($_.Name -eq '.editorconfig') { return $false }
    if ($_.Name -eq 'build.sh') { return $false }
    if ($_.Name -eq 'build.ps1') { return $false }
    return $true
}

if (-not $files) {
    Write-Error "No files found to archive."
    exit 1
}

$zip = [System.IO.Compression.ZipFile]::Open($Destination, [System.IO.Compression.ZipArchiveMode]::Create)
try {
    foreach ($f in $files) {
        $rel = $f.FullName.Substring($base.Length)
        $rel = $rel -replace '\\','/'
        $entryName = $rel
        [void][System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $f.FullName, $entryName, [System.IO.Compression.CompressionLevel]::Optimal)
    }
}
finally {
    $zip.Dispose()
}

Write-Output "Modpack packed as $Destination"

if ($Version) {
    $versionedDest = "Alpaka-Modpack-$Version.mrpack"
    Copy-Item $Destination $versionedDest -Force
    Write-Output "Created versioned package: $versionedDest"
}
