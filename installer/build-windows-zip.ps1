$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$releaseDir = Join-Path $projectRoot 'build\windows\x64\runner\Release'
$outputDir = Join-Path $projectRoot 'build\installer'
$zipPath = Join-Path $outputDir 'Wholesale-Manager-Windows-x64.zip'

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  throw 'Flutter was not found on PATH. Install Flutter and reopen PowerShell.'
}

Push-Location $projectRoot
try {
  flutter build windows --release
  if ($LASTEXITCODE -ne 0) {
    throw "Flutter Windows release build failed with exit code $LASTEXITCODE."
  }
}
finally {
  Pop-Location
}

$executablePath = Join-Path $releaseDir 'wholesale_manager.exe'
if (-not (Test-Path -LiteralPath $executablePath -PathType Leaf)) {
  throw "Windows release executable was not created at '$executablePath'."
}

New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
if (Test-Path -LiteralPath $zipPath) {
  Remove-Item -LiteralPath $zipPath -Force
}

Compress-Archive -Path (Join-Path $releaseDir '*') `
  -DestinationPath $zipPath `
  -CompressionLevel Optimal

Write-Output "Created $zipPath"
