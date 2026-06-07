<#
    deploy.ps1 — push the fork's theme into every local Obsidian vault
    that has the "LYT Mode" theme folder.

    Source of truth = this repo's theme.css + manifest.json.
    Run on desktop after committing a change:  .\deploy.ps1
    Obsidian Sync then carries the updated theme to your phone per-vault.

    -WhatIf  : list what WOULD be copied without copying.
#>
param([switch]$WhatIf)

$ErrorActionPreference = 'Stop'
$repo = $PSScriptRoot
$files = @('theme.css', 'manifest.json')

# Roots to scan for vaults (folders containing .obsidian/themes/LYT Mode)
$roots = @(
    'C:\vaults-nano',
    'C:\Users\bibleman\Documents'
)

$targets = foreach ($root in $roots) {
    if (Test-Path $root) {
        # Anchor on .obsidian config folders (hidden -> -Force), then check for the theme.
        Get-ChildItem -Path $root -Directory -Recurse -Depth 3 -Force -Filter '.obsidian' -ErrorAction SilentlyContinue |
            ForEach-Object { Join-Path $_.FullName 'themes\LYT Mode' } |
            Where-Object { Test-Path $_ } |
            ForEach-Object { Get-Item $_ }
    }
}
$targets = $targets | Sort-Object FullName -Unique

if (-not $targets) { Write-Host 'No "LYT Mode" theme folders found.' -ForegroundColor Yellow; return }

$count = 0
foreach ($t in $targets) {
    $vault = $t.Parent.Parent.Parent.Name
    foreach ($f in $files) {
        $src = Join-Path $repo $f
        $dst = Join-Path $t.FullName $f
        if ($WhatIf) {
            Write-Host "WOULD copy $f -> $vault"
        } else {
            Copy-Item -Path $src -Destination $dst -Force
        }
    }
    if (-not $WhatIf) { Write-Host "  deployed -> $vault" -ForegroundColor Green }
    $count++
}
Write-Host ("`n{0} vault(s) {1}." -f $count, $(if ($WhatIf) {'would be updated'} else {'updated'}))
if (-not $WhatIf) { Write-Host 'Obsidian Sync will carry these to your other devices (phone) per-vault.' -ForegroundColor Cyan }
