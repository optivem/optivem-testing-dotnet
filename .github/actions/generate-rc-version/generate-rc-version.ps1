#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Generates RC version by appending -rc.N suffix to base version

.PARAMETER BaseVersion
    Base semantic version (e.g., 1.0.0)

.PARAMETER RunNumber
    Build run number for RC suffix

.EXAMPLE
    .\generate-rc-version.ps1 -BaseVersion "1.0.0" -RunNumber "12"
    Output: 1.0.0-rc.12
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$BaseVersion,
    
    [Parameter(Mandatory=$true)]
    [string]$RunNumber
)

# Validate base version format (X.Y.Z)
if ($BaseVersion -notmatch '^\d+\.\d+\.\d+$') {
    Write-Host "❌ Invalid base version format. Expected: X.Y.Z (semantic versioning)" -ForegroundColor Red
    Write-Host "   Got: $BaseVersion" -ForegroundColor Yellow
    exit 1
}

# Generate RC version
$rcVersion = "$BaseVersion-rc.$RunNumber"

Write-Host "🏷️  Generated RC version: $rcVersion" -ForegroundColor Green
Write-Host "   Base version: $BaseVersion" -ForegroundColor Gray
Write-Host "   Run number: $RunNumber" -ForegroundColor Gray

# Output for GitHub Actions
if ($env:GITHUB_OUTPUT) {
    "rc-version=$rcVersion" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
} else {
    # Local testing output
    Write-Host "RC Version: $rcVersion"
}
