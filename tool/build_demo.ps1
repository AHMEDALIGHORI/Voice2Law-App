# Voice2Law demo-artifact build script.
#
# Builds the web bundle and signed Android release with your own AI keys
# compiled in via --dart-define. Keys are read from environment variables
# and are never written to source files.
#
# Usage (PowerShell):
#   $env:GEMINI_API_KEY='your-key'
#   $env:GROQ_API_KEY='your-key'
#   powershell -File tool/build_demo.ps1          # web + APK
#   powershell -File tool/build_demo.ps1 -Target web   # web only
#   powershell -File tool/build_demo.ps1 -Target apk   # APK only
#
# Optional: SEENA_API_KEY and SEENA_BASE_URL are forwarded when set.

[CmdletBinding()]
param(
  [ValidateSet('both', 'web', 'apk')]
  [string]$Target = 'both'
)

$ErrorActionPreference = 'Stop'

function Require-Env([string]$Name) {
  $value = [Environment]::GetEnvironmentVariable($Name)
  if ([string]::IsNullOrWhiteSpace($value)) {
    Write-Error "Environment variable $Name is not set. It is required for the demo build."
  }
  return $value
}

$geminiKey = Require-Env 'GEMINI_API_KEY'
$groqKey = Require-Env 'GROQ_API_KEY'
$defines = @(
  '--dart-define=GEMINI_API_KEY=' + $geminiKey,
  '--dart-define=GROQ_API_KEY=' + $groqKey
)

$seenaKey = [Environment]::GetEnvironmentVariable('SEENA_API_KEY')
$seenaBaseUrl = [Environment]::GetEnvironmentVariable('SEENA_BASE_URL')
if (-not [string]::IsNullOrWhiteSpace($seenaKey)) {
  $defines += '--dart-define=SEENA_API_KEY=' + $seenaKey
}
if (-not [string]::IsNullOrWhiteSpace($seenaBaseUrl)) {
  $defines += '--dart-define=SEENA_BASE_URL=' + $seenaBaseUrl
}

Push-Location $PSScriptRoot\..
try {
  if ($Target -in @('both', 'web')) {
    Write-Host 'Building web release...' -ForegroundColor Cyan
    flutter build web --release @defines
    if ($LASTEXITCODE -ne 0) { throw "flutter build web failed (exit $LASTEXITCODE)" }
    Write-Host 'Web build complete -> build/web' -ForegroundColor Green
  }
  if ($Target -in @('both', 'apk')) {
    Write-Host 'Building signed Android release...' -ForegroundColor Cyan
    flutter build apk --release @defines
    if ($LASTEXITCODE -ne 0) { throw "flutter build apk failed (exit $LASTEXITCODE)" }
    $release = 'releases\Voice2Law-1.2.0-release.apk'
    New-Item -ItemType Directory -Force -Path 'releases' | Out-Null
    Copy-Item 'build\app\outputs\flutter-apk\app-release.apk' $release -Force
    Write-Host "Release APK staged -> $release" -ForegroundColor Green
  }
}
finally {
  Pop-Location
}
