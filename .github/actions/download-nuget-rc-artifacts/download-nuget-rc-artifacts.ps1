#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Downloads NuGet RC artifacts from GitHub Packages

.PARAMETER RcVersion
    The RC version to download

.PARAMETER GitHubUsername
    GitHub username for authentication

.PARAMETER GitHubToken
    GitHub token for authentication

.PARAMETER Repository
    GitHub repository (owner/repo)

.PARAMETER PackageName
    NuGet package name (default: Optivem.Testing)

.EXAMPLE
    .\download-nuget-rc-artifacts.ps1 -RcVersion "2026.02.05-rc.47" -GitHubUsername "user" -GitHubToken $token -Repository "optivem/optivem-testing-dotnet"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$RcVersion,
    
    [Parameter(Mandatory=$true)]
    [string]$GitHubUsername,
    
    [Parameter(Mandatory=$true)]
    [string]$GitHubToken,
    
    [Parameter(Mandatory=$true)]
    [string]$Repository,
    
    [Parameter(Mandatory=$false)]
    [string]$PackageName = "Optivem.Testing"
)

Write-Host "📥 Downloading NuGet RC package from GitHub Packages..." -ForegroundColor Blue
Write-Host "   Package: $PackageName" -ForegroundColor Gray
Write-Host "   Version: $RcVersion" -ForegroundColor Gray
Write-Host "" -ForegroundColor Gray

New-Item -ItemType Directory -Path "temp-artifacts" -Force | Out-Null

# Extract owner from repository
$owner = $Repository.Split('/')[0]

# Configure NuGet source for GitHub Packages
$sourceName = "github-temp"
Write-Host "🔧 Configuring temporary NuGet source..." -ForegroundColor Yellow

# Remove source if it already exists
dotnet nuget remove source $sourceName 2>$null | Out-Null

# Add GitHub Packages as NuGet source
dotnet nuget add source "https://nuget.pkg.github.com/$owner/index.json" `
    --name $sourceName `
    --username $GitHubUsername `
    --password $GitHubToken `
    --store-password-in-clear-text | Out-Null

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to configure NuGet source" -ForegroundColor Red
    exit 1
}

Write-Host "✅ NuGet source configured" -ForegroundColor Green

# Download the package
$packageFileName = "$PackageName.$RcVersion.nupkg"
$outputPath = "temp-artifacts\$packageFileName"

Write-Host "" -ForegroundColor Gray
Write-Host "⬇️  Downloading $packageFileName..." -ForegroundColor Yellow

$maxRetries = 3
$retryCount = 0
$success = $false

while (-not $success -and $retryCount -lt $maxRetries) {
    try {
        # Use dotnet to download the package
        Push-Location "temp-artifacts"
        dotnet add package $PackageName --version $RcVersion --source $sourceName --package-directory . 2>&1 | Out-Null
        Pop-Location
        
        # Find the downloaded nupkg (case-insensitive search)
        $packageNameLower = $PackageName.ToLower()
        $expectedPattern = "*$packageNameLower.$RcVersion.nupkg"
        $downloadedPackage = Get-ChildItem -Path "temp-artifacts" -Filter "*.nupkg" -Recurse | Where-Object { $_.Name -like $expectedPattern }
        
        if ($downloadedPackage) {
            # Move to root of temp-artifacts if in subdirectory
            if ($downloadedPackage.DirectoryName -ne (Resolve-Path "temp-artifacts").Path) {
                Move-Item -Path $downloadedPackage.FullName -Destination $outputPath -Force
            } else {
                # Rename to expected casing if needed
                if ($downloadedPackage.Name -ne $packageFileName) {
                    Rename-Item -Path $downloadedPackage.FullName -NewName $packageFileName -Force
                }
            }
            Write-Host "✅ Downloaded $packageFileName" -ForegroundColor Green
            $success = $true
        } else {
            throw "Package file not found after download"
        }
    } catch {
        $retryCount++
        if ($retryCount -lt $maxRetries) {
            Write-Host "⚠️  Attempt $retryCount failed, retrying in 5 seconds..." -ForegroundColor Yellow
            Start-Sleep -Seconds 5
        } else {
            Write-Host "❌ Failed to download package after $maxRetries attempts: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "💡 Ensure the RC package is published to GitHub Packages" -ForegroundColor Cyan
            
            # Cleanup
            dotnet nuget remove source $sourceName 2>$null | Out-Null
            exit 1
        }
    }
}

# Cleanup temporary source
Write-Host "" -ForegroundColor Gray
Write-Host "🧹 Cleaning up temporary NuGet source..." -ForegroundColor Yellow
dotnet nuget remove source $sourceName 2>$null | Out-Null

Write-Host "" -ForegroundColor Gray
Write-Host "✅ NuGet package downloaded successfully" -ForegroundColor Green
Write-Host "   Location: $outputPath" -ForegroundColor Gray