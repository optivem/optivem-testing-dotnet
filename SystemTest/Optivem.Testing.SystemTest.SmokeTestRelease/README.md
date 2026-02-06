# Smoke Test Release

This module verifies the release version of optivem-testing library published to NuGet.org.

## Purpose

- Tests the published release version from NuGet.org
- Ensures the library is correctly published and accessible
- Validates basic functionality of the released artifacts
- Simulates real-world consumer experience of the package

## Key Differences from Smoke Test RC

Unlike `Optivem.Testing.SystemTest.SmokeTestRc` which tests RC versions from GitHub Packages:
- References `Optivem.Testing` from **NuGet.org only** (no GitHub Packages)
- Tests **stable release versions** (e.g., 1.0.2) not RC versions
- Uses wildcard version `*` to resolve the latest release version
- Validates the package accessible to public consumers

## Running Tests

```bash
cd SystemTest/Optivem.Testing.SystemTest.SmokeTestRelease
dotnet restore
dotnet test
```

## Configuration

The `nuget.config` file is configured to:
- Use only NuGet.org as the package source
- NOT include GitHub Packages (unlike SmokeTestRc)
- Ensure tests validate public package availability

## CI/CD Integration

These tests can run:
- After manual verification that a release version is indexed on NuGet.org
- To validate that published releases work correctly
- Before creating GitHub releases
- As scheduled health checks for published packages
