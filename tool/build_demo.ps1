# Voice2Law release-artifact build script.
#
# API keys are deliberately NOT compiled into the binary: anything passed with
# --dart-define can be extracted from the APK or web bundle. Either point the
# app at a backend that holds the keys (`API_BASE_URL`), or let users paste
# their own key in Settings (stored with platform secure storage).
#
# Usage (PowerShell):
#   $env:API_BASE_URL='https://api.example.org/api'
#   powershell -File tool/build_demo.ps1          # web + APK
#   powershell -File tool/build_demo.ps1 -Target web   # web only
#   powershell -File tool/build_demo.ps1 -Target apk   # APK only
#
# Optional: SEENA_BASE_URL is forwarded when set (a URL, not a secret).

[CmdletBinding()]
param(
  [ValidateSet('both', 'web', 'apk')]
  [string]$Target = 'both'
)

$ErrorActionPreference = 'Stop'

function Get-OptionalEnv([string]$Name) {
  return [Environment]::GetEnvironmentVariable($Name)
}

$defines = @()

$apiBaseUrl = Get-OptionalEnv 'API_BASE_URL'
if (-not [string]::IsNullOrWhiteSpace($apiBaseUrl)) {
  $defines += '--dart-define=API_BASE_URL=' + $apiBaseUrl
}

$seenaBaseUrl = Get-OptionalEnv 'SEENA_BASE_URL'
if (-not [string]::IsNullOrWhiteSpace($seenaBaseUrl)) {
  $defines += '--dart-define=SEENA_BASE_URL=' + $seenaBaseUrl
}

foreach ($secret in @('GEMINI_API_KEY', 'GROQ_API_KEY', 'SEENA_API_KEY')) {
  if (-not [string]::IsNullOrWhiteSpace((Get-OptionalEnv $secret))) {
    Write-Warning "$secret is set but will be ignored: API keys are never compiled into the app."
  }
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
    Write-Host "Release APK staged -> $release (gitignored)" -ForegroundColor Green
  }
}
finally {
  Pop-Location
}
