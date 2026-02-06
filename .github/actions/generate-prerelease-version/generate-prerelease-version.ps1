#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Generates prerelease version by appending -<label>.N suffix to base version

.PARAMETER BaseVersion
    Base semantic version (e.g., 1.0.0)

.PARAMETER RunNumber
    Build run number for prerelease suffix

.PARAMETER PrereleaseLabel
    Prerelease label (e.g., rc, beta, alpha)

.EXAMPLE
    .\generate-prerelease-version.ps1 -BaseVersion "1.0.0" -RunNumber "12" -PrereleaseLabel "rc"
    Output: 1.0.0-rc.12
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$BaseVersion,
    
    [Parameter(Mandatory=$true)]
    [string]$RunNumber,

    [Parameter(Mandatory=$false)]
    [string]$PrereleaseLabel = "rc"
)

# Validate base version format (X.Y.Z)
if ($BaseVersion -notmatch '^\d+\.\d+\.\d+$') {
    Write-Host "❌ Invalid base version format. Expected: X.Y.Z (semantic versioning)" -ForegroundColor Red
    Write-Host "   Got: $BaseVersion" -ForegroundColor Yellow
    exit 1
}

# Validate prerelease label format (semver prerelease identifier)
if ($PrereleaseLabel -notmatch '^[0-9A-Za-z-]+$') {
    Write-Host "❌ Invalid prerelease label. Expected: [0-9A-Za-z-]+" -ForegroundColor Red
    Write-Host "   Got: $PrereleaseLabel" -ForegroundColor Yellow
    exit 1
}

# Generate prerelease version
$rcVersion = "$BaseVersion-$PrereleaseLabel.$RunNumber"

Write-Host "🏷️  Generated prerelease version: $rcVersion" -ForegroundColor Green
Write-Host "   Base version: $BaseVersion" -ForegroundColor Gray
Write-Host "   Run number: $RunNumber" -ForegroundColor Gray
Write-Host "   Prerelease label: $PrereleaseLabel" -ForegroundColor Gray

# Output for GitHub Actions
if ($env:GITHUB_OUTPUT) {
    "rc-version=$rcVersion" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
} else {
    # Local testing output
    Write-Host "Prerelease Version: $rcVersion"
}
