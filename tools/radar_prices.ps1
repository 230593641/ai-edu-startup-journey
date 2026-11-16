# tools/radar_prices.ps1
# Purpose: use OpenRouter's public model catalog as a price API, fetch the watchlist
#          prices/context lengths, diff against last snapshot, print changes.
#          Feeds the "models & pricing" step of the weekly AI radar (doc 14).
# Run: powershell -NoProfile -ExecutionPolicy Bypass -File tools\radar_prices.ps1
# Note: keep this file ASCII-only. Windows PowerShell 5.1 reads UTF-8 without BOM as
#       ANSI and breaks on non-ASCII comments (verified on this machine).

$ErrorActionPreference = 'Stop'
$snapPath = Join-Path $PSScriptRoot 'price_snapshot.json'
$api = 'https://openrouter.ai/api/v1/models'

# Watchlist (regex against model id). Edit here to change what is tracked.
$watch = @(
    'anthropic/claude-fable-5\.2',
    'anthropic/claude-opus-5\.5',
    'qwen/qwen4-max',
    'deepseek/deepseek-v4\.1-flash-1017',
    'deepseek/deepseek-v4-pro-0813'
)

$tmp = Join-Path $env:TEMP ('or-' + [guid]::NewGuid().ToString('N') + '.json')
curl.exe -sS --ssl-no-revoke --max-time 30 $api -o $tmp | Out-Null
if (-not (Test-Path $tmp)) { throw 'fetch failed' }
$data = (Get-Content $tmp -Raw | ConvertFrom-Json).data
Remove-Item $tmp -Force

$rows = @()
foreach ($m in $data) {
    foreach ($w in $watch) {
        if ($m.id -match ('^' + $w + '(:batch)?$')) {
            $rows += [pscustomobject]@{
                id  = $m.id
                ctx = [int64]$m.context_length
                inp = [math]::Round([double]$m.pricing.prompt * 1e6, 4)
                out = [math]::Round([double]$m.pricing.completion * 1e6, 4)
            }
        }
    }
}
$rows = @($rows | Sort-Object id)

Write-Output '=== current prices (USD / 1M tokens) ==='
$rows | Format-Table -AutoSize | Out-String -Width 200 | Write-Output

if (Test-Path $snapPath) {
    $old = @{}
    foreach ($r in (Get-Content $snapPath -Raw | ConvertFrom-Json)) { $old[$r.id] = $r }
    $changes = @()
    foreach ($r in $rows) {
        if ($old.ContainsKey($r.id)) {
            $o = $old[$r.id]
            if ($o.inp -ne $r.inp -or $o.out -ne $r.out) {
                $changes += "CHANGED  $($r.id): in $($o.inp) -> $($r.inp)  out $($o.out) -> $($r.out)"
            }
        } else { $changes += "NEW      $($r.id): in $($r.inp) out $($r.out)" }
    }
    foreach ($k in $old.Keys) { if (-not ($rows.id -contains $k)) { $changes += "GONE     $k" } }
    if ($changes.Count -gt 0) { Write-Output '=== changes ==='; $changes } else { Write-Output '=== changes: none ===' }
} else {
    Write-Output '=== first run, snapshot written ==='
}

$rows | ConvertTo-Json -Depth 4 | Set-Content -Path $snapPath -Encoding UTF8
Write-Output ('snapshot -> ' + (Resolve-Path $snapPath).Path)
