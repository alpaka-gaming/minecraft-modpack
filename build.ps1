#!/usr/bin/env pwsh

# Pack `src` into a .mrpack (zip) while excluding common patterns
$Destination = "Alpaka-Modpack.mrpack"
$SourceDir = "src"

if (-not (Test-Path $SourceDir)) {
    Write-Error "Source directory '$SourceDir' not found."
    exit 1
}

if (Test-Path $Destination) {
    Remove-Item $Destination -Force
}

Add-Type -AssemblyName System.IO.Compression.FileSystem

$base = (Get-Item $SourceDir).FullName
if (-not $base.EndsWith('\')) { $base += '\' }
$rootName = (Get-Item $SourceDir).Name

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
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $f.FullName, $entryName, [System.IO.Compression.CompressionLevel]::Optimal)
    }
}
finally {
    $zip.Dispose()
}

Write-Output "Modpack packed as $Destination"
