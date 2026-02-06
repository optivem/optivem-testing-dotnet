#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Extracts release version from RC version

.PARAMETER PrereleaseVersion
    The prerelease version to validate in semantic versioning format (e.g., 1.0.5-rc.47)

.EXAMPLE
    .\extract-release-version.ps1 -PrereleaseVersion "1.0.5-rc.47"
    .\extract-release-version.ps1 -PrereleaseVersion "2.1.0-rc.3"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$PrereleaseVersion
)

# Validate semantic versioning format: X.Y.Z-rc.N
if ($PrereleaseVersion -notmatch '^\d+\.\d+\.\d+-rc\.\d+$') {
    Write-Host "❌ Invalid RC version format. Expected: X.Y.Z-rc.N (semantic versioning)" -ForegroundColor Red
    Write-Host "   Example: 1.0.0-rc.12, 2.1.5-rc.3" -ForegroundColor Yellow
    exit 1
}

# Extract release version (remove -rc.N suffix)
$releaseVersion = $PrereleaseVersion -replace '-rc\.[0-9]+$', ''

Write-Host "🔄 Promoting RC $PrereleaseVersion → Release $releaseVersion" -ForegroundColor Cyan

# Output for GitHub Actions
if ($env:GITHUB_OUTPUT) {
    "release_version=${releaseVersion}" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
} else {
    # Local testing output
    Write-Host "RC Version: $PrereleaseVersion"
    Write-Host "Release Version: $releaseVersion"
}