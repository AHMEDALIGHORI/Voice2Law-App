$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot
$runtime = Join-Path $PSScriptRoot '.venv\Scripts\python.exe'
if (-not (Test-Path -LiteralPath $runtime)) { throw 'Run setup.ps1 first.' }
if (-not (Test-Path -LiteralPath '.pairing-key')) {
    $pairBytes = New-Object byte[] 18
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $rng.GetBytes($pairBytes)
    $rng.Dispose()
    [Convert]::ToBase64String($pairBytes) | Set-Content -LiteralPath '.pairing-key' -NoNewline
}
Write-Host 'Voice2Law: no paid APIs; keep this PC running on the same trusted Wi-Fi as your phone.'
Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -match '^(192\.168\.|10\.|172\.(1[6-9]|2[0-9]|3[01])\.)' } | ForEach-Object { Write-Host "Phone server URL: http://$($_.IPAddress):8765" }
Write-Host "Pairing key: $(Get-Content -LiteralPath '.pairing-key')"
Write-Host 'Enter these under Preferences > Free local languages. HTTP is unencrypted: use trusted private Wi-Fi only.'
Write-Host 'If Windows asks, allow Python on Private networks only. Do not forward port 8765 on your router.'
$env:HF_HUB_OFFLINE = '1'
$env:HF_HUB_DISABLE_TELEMETRY = '1'
& $runtime -m uvicorn server:app --host 0.0.0.0 --port 8765 --no-access-log --no-proxy-headers
