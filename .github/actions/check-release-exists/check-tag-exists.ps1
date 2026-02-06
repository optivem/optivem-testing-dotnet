#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Checks if a Git tag already exists.

.PARAMETER ReleaseVersion
    The release version to check.

.EXAMPLE
    .\check-tag-exists.ps1 -ReleaseVersion "2026.02.05"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$ReleaseVersion
)

Write-Host "🔍 Checking if Git tag v$ReleaseVersion exists..." -ForegroundColor Cyan

$tagExists = git rev-parse "v$ReleaseVersion" 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "❌ Git tag v$ReleaseVersion already exists" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Git tag v$ReleaseVersion does not exist" -ForegroundColor Green
