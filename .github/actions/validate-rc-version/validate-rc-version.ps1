#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Validates RC version format and extracts release version.

.PARAMETER RcVersion
    The RC version to validate (e.g., 2026.02.05-rc.47).

.EXAMPLE
    .\validate-rc-version.ps1 -RcVersion "2026.02.05-rc.47"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$RcVersion
)

# Validate RC version format (YYYY.MM.DD-rc.N)
if ($RcVersion -notmatch '^\d{4}\.\d{2}\.\d{2}-rc\.\d+$') {
    Write-Host "❌ Invalid RC version format. Expected: YYYY.MM.DD-rc.N, got: $RcVersion" -ForegroundColor Red
    exit 1
}

# Extract release version (remove -rc.N suffix)
$releaseVersion = $RcVersion -replace '-rc\.\d+$', ''

Write-Host "🔄 Promoting RC $RcVersion → Release $releaseVersion" -ForegroundColor Cyan

# Output for GitHub Actions
if ($env:GITHUB_OUTPUT) {
    "rc_version=${RcVersion}" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
    "release_version=${releaseVersion}" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
} else {
    # Local testing output
    Write-Host "RC Version: $RcVersion"
    Write-Host "Release Version: $releaseVersion"
}
