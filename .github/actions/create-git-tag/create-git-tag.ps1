#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Creates and pushes a Git tag for the release version.

.PARAMETER ReleaseVersion
    The release version for the tag.

.PARAMETER RcVersion
    The RC version being promoted.

.EXAMPLE
    .\create-git-tag.ps1 -ReleaseVersion "2026.02.05" -RcVersion "2026.02.05-rc.47"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$ReleaseVersion,
    
    [Parameter(Mandatory=$true)]
    [string]$RcVersion
)

Write-Host "🏷️  Creating Git tag v$ReleaseVersion..." -ForegroundColor Cyan

# Configure Git
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

# Create annotated tag
git tag -a "v$ReleaseVersion" -m "Release $ReleaseVersion (promoted from $RcVersion)"

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to create Git tag" -ForegroundColor Red
    exit 1
}

# Push tag
git push origin "v$ReleaseVersion"

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to push Git tag" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Created and pushed Git tag v$ReleaseVersion" -ForegroundColor Green
