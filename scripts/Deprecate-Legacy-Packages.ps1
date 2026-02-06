#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Deprecates and unlists all legacy Optivem packages

.DESCRIPTION
    This script processes all packages starting with:
    - Optivem.Framework
    - Optivem.Atomiv
    
    For each package, it:
    1. Unlists all versions
    2. Attempts to deprecate them
    
.PARAMETER DryRun
    If specified, only lists packages without making changes

.PARAMETER ApiKey
    NuGet.org API key (if not provided, will look for NUGET_API_KEY env var)

.EXAMPLE
    # Preview what will be done
    .\Deprecate-Legacy-Packages.ps1 -DryRun
    
    # Actually run the deprecation
    .\Deprecate-Legacy-Packages.ps1
#>

param(
    [Parameter(Mandatory=$false)]
    [switch]$DryRun,
    
    [Parameter(Mandatory=$false)]
    [string]$ApiKey = $env:NUGET_API_KEY
)

$ErrorActionPreference = "Stop"

# List of packages to deprecate
$packages = @(
    # Optivem.Framework.Core packages
    "Optivem.Framework.Core.Common",
    "Optivem.Framework.Core.Domain",
    "Optivem.Framework.Core.Application.Interface",
    "Optivem.Framework.Core.Application",
    "Optivem.Framework.Core.All",
    "Optivem.Framework.Core.Common.Serialization",
    
    # Optivem.Framework.Infrastructure packages
    "Optivem.Framework.Infrastructure.FluentValidation",
    "Optivem.Framework.Infrastructure.NewtonsoftJson",
    "Optivem.Framework.Infrastructure.System",
    "Optivem.Framework.Infrastructure.EntityFrameworkCore",
    "Optivem.Framework.Infrastructure.Selenium",
    "Optivem.Framework.Infrastructure.CsvHelper",
    "Optivem.Framework.Infrastructure.AutoMapper",
    "Optivem.Framework.Infrastructure.MediatR",
    "Optivem.Framework.Infrastructure.AspNetCore",
    "Optivem.Framework.Infrastructure.EPPlus",
    "Optivem.Framework.Infrastructure.Common.Serialization.Json.NewtonsoftJson",
    
    # Optivem.Framework.DependencyInjection packages
    "Optivem.Framework.DependencyInjection.Common",
    "Optivem.Framework.DependencyInjection.Infrastructure.FluentValidation",
    "Optivem.Framework.DependencyInjection.Infrastructure.NewtonsoftJson",
    "Optivem.Framework.DependencyInjection.Infrastructure.AutoMapper",
    "Optivem.Framework.DependencyInjection.Infrastructure.MediatR",
    "Optivem.Framework.DependencyInjection.Infrastructure.EntityFrameworkCore",
    "Optivem.Framework.DependencyInjection.Core.Domain",
    "Optivem.Framework.DependencyInjection.Core.Application",
    
    # Optivem.Framework.Web packages
    "Optivem.Framework.Web.AspNetCore",
    
    # Optivem.Framework.Test packages
    "Optivem.Framework.Test.Common",
    "Optivem.Framework.Test.MicrosoftExtensions",
    "Optivem.Framework.Test.AspNetCore",
    "Optivem.Framework.Test.Xunit",
    "Optivem.Framework.Test.Selenium",
    "Optivem.Framework.Test.EntityFrameworkCore",
    "Optivem.Framework.Test.FluentAssertions",
    
    # Optivem.Atomiv.Core packages
    "Optivem.Atomiv.Core.Common",
    "Optivem.Atomiv.Core.Domain",
    "Optivem.Atomiv.Core.Application.Interface",
    "Optivem.Atomiv.Core.Application",
    "Optivem.Atomiv.Core.All",
    
    # Optivem.Atomiv.Infrastructure packages
    "Optivem.Atomiv.Infrastructure.System",
    "Optivem.Atomiv.Infrastructure.NewtonsoftJson",
    "Optivem.Atomiv.Infrastructure.FluentValidation",
    "Optivem.Atomiv.Infrastructure.EntityFrameworkCore",
    "Optivem.Atomiv.Infrastructure.AspNetCore",
    "Optivem.Atomiv.Infrastructure.AutoMapper",
    "Optivem.Atomiv.Infrastructure.MediatR",
    "Optivem.Atomiv.Infrastructure.Selenium",
    "Optivem.Atomiv.Infrastructure.EPPlus",
    "Optivem.Atomiv.Infrastructure.CsvHelper",
    "Optivem.Atomiv.Infrastructure.SequentialGuid",
    
    # Optivem.Atomiv.DependencyInjection packages
    "Optivem.Atomiv.DependencyInjection.Common",
    "Optivem.Atomiv.DependencyInjection.Infrastructure.AspNetCore",
    "Optivem.Atomiv.DependencyInjection.Infrastructure.FluentValidation",
    "Optivem.Atomiv.DependencyInjection.Infrastructure.NewtonsoftJson",
    "Optivem.Atomiv.DependencyInjection.Infrastructure.MediatR",
    "Optivem.Atomiv.DependencyInjection.Infrastructure.System",
    "Optivem.Atomiv.DependencyInjection.Infrastructure.AutoMapper",
    "Optivem.Atomiv.DependencyInjection.Infrastructure.EntityFrameworkCore",
    "Optivem.Atomiv.DependencyInjection.Core.Domain",
    "Optivem.Atomiv.DependencyInjection.Core.Application",
    
    # Optivem.Atomiv.Web packages
    "Optivem.Atomiv.Web.AspNetCore",
    
    # Optivem.Atomiv.Test packages
    "Optivem.Atomiv.Test.MicrosoftExtensions",
    "Optivem.Atomiv.Test.AspNetCore",
    "Optivem.Atomiv.Test.FluentAssertions",
    "Optivem.Atomiv.Test.Xunit",
    "Optivem.Atomiv.Test.Selenium",
    "Optivem.Atomiv.Test.EntityFrameworkCore",
    
    # Optivem.Atomiv.Templates
    "Optivem.Atomiv.Templates",
    
    # Optivem.Platform.Core packages
    "Optivem.Platform.Core.Common.Repository",
    "Optivem.Platform.Core.Application.Service",
    "Optivem.Platform.Core.Common.Parsing",
    "Optivem.Platform.Core.Common.WebAutomation",
    "Optivem.Platform.Core.Common.RestClient",
    "Optivem.Platform.Core.Common.Serialization",
    "Optivem.Platform.Core.Common.Mapping",
    "Optivem.Platform.Core.Application.Service.Default",
    
    # Optivem.Platform.Infrastructure packages
    "Optivem.Platform.Infrastructure.Common.Serialization.Csv.CsvHelper",
    "Optivem.Platform.Infrastructure.Common.Serialization.Json.NewtonsoftJson",
    "Optivem.Platform.Infrastructure.Common.Repository.EntityFrameworkCore",
    "Optivem.Platform.Infrastructure.Common.WebAutomation.Selenium",
    "Optivem.Platform.Infrastructure.Common.Serialization.Default",
    "Optivem.Platform.Infrastructure.Common.RestClient.Default",
    "Optivem.Platform.Infrastructure.Common.Parsing.Default",
    "Optivem.Platform.Infrastructure.Common.Mapping.AutoMapper",
    
    # Optivem.Platform.Web packages
    "Optivem.Platform.Web.AspNetCore.Rest",
    
    # Optivem.Core packages
    "Optivem.Core.Common",
    "Optivem.Core.All",
    "Optivem.Core.Application.Interface",
    "Optivem.Core.Domain",
    "Optivem.Core.Application",
    
    # Optivem.Common packages
    "Optivem.Common.Serialization",
    
    # Optivem.Infrastructure packages
    "Optivem.Infrastructure.Mapping.AutoMapper",
    "Optivem.Infrastructure.Serialization.CsvHelper",
    "Optivem.Infrastructure.CsvHelper",
    "Optivem.Infrastructure.NewtonsoftJson",
    
    # Optivem.Web packages
    "Optivem.Web.AspNetCore",
    
    # Optivem.Templates
    "Optivem.Templates",
    "Optivem.Template"
)

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   Legacy Package Deprecation Script" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "🔍 DRY RUN MODE - No changes will be made" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "📦 Found $($packages.Count) packages to process:" -ForegroundColor White
Write-Host ""
foreach ($pkg in $packages) {
    Write-Host "  • $pkg" -ForegroundColor Gray
}
Write-Host ""

if ($DryRun) {
    Write-Host "✓ Dry run complete. Use without -DryRun to actually deprecate packages." -ForegroundColor Green
    exit 0
}

# Confirm with user
Write-Host "⚠️  WARNING: This will unlist and deprecate all versions of these packages!" -ForegroundColor Yellow
Write-Host ""
$confirmation = Read-Host "Type 'YES' to proceed"
if ($confirmation -ne 'YES') {
    Write-Host "❌ Operation cancelled by user" -ForegroundColor Red
    exit 1
}

if ([string]::IsNullOrEmpty($ApiKey)) {
    Write-Host "❌ API key not provided. Set NUGET_API_KEY environment variable" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   Starting Package Deprecation" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$successCount = 0
$failCount = 0
$skippedCount = 0

foreach ($packageId in $packages) {
    Write-Host ""
    Write-Host "──────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "📦 Processing: $packageId" -ForegroundColor Cyan
    Write-Host "──────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    
    try {
        # Call the single package script
        $scriptPath = Join-Path $PSScriptRoot "Deprecate-Package.ps1"
        
        & $scriptPath -PackageId $packageId -ApiKey $ApiKey
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Successfully processed $packageId" -ForegroundColor Green
            $successCount++
        } else {
            Write-Host "⚠️  Failed to process $packageId" -ForegroundColor Yellow
            $failCount++
        }
        
    } catch {
        Write-Host "❌ Error processing $packageId`: $_" -ForegroundColor Red
        $failCount++
    }
    
    # Small delay between packages to avoid rate limiting
    Start-Sleep -Seconds 2
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   Summary" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ Successfully processed: $successCount" -ForegroundColor Green
Write-Host "❌ Failed: $failCount" -ForegroundColor Red
Write-Host "📊 Total packages: $($packages.Count)" -ForegroundColor White
Write-Host ""
Write-Host "📝 Remember to manually deprecate on NuGet.org:" -ForegroundColor Yellow
Write-Host "   https://www.nuget.org/profiles/optivem" -ForegroundColor Cyan
Write-Host ""
