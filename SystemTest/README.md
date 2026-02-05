# System Tests

This directory contains system-level tests that verify the published packages work correctly.

## Smoke Test RC

The `Optivem.Testing.SystemTest.SmokeTestRc` project tests the Release Candidate (RC) packages published to GitHub Packages.

### Purpose

- Validates that the RC package can be resolved from GitHub Packages
- Verifies the package API works correctly when consumed as a NuGet dependency
- Runs smoke tests to ensure critical functionality is working

### Key Differences from Unit Tests

Unlike `Optivem.Testing.Tests` which uses project references, this test project:
- References `Optivem.Testing` as a NuGet package (not a project reference)
- Consumes the RC version published to GitHub Packages
- Simulates how end-users will consume the package
- Runs as part of the acceptance stage in the deployment pipeline

### Running Locally

To run these tests locally against a specific RC version:

```bash
cd SystemTest/Optivem.Testing.SystemTest.SmokeTestRc
dotnet restore
dotnet test
```

### CI/CD Integration

These tests run automatically:
- Every hour via scheduled workflow
- As part of the acceptance stage after RC packages are published
- Before promoting an RC to a stable release
