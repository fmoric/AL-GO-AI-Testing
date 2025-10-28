<#
.SYNOPSIS
    Demonstration script for the Business Central License Manager.

.DESCRIPTION
    This script demonstrates the complete workflow of the License Manager system,
    including key generation, license creation, signing, and verification.
    It creates sample licenses for demonstration purposes.

.EXAMPLE
    .\Demo-LicenseManager.ps1
    Runs the complete demonstration workflow
#>

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "  Business Central License Manager Demo" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

$scriptDir = $PSScriptRoot

# Step 1: Generate RSA Key Pair
Write-Host "`nStep 1: Generating RSA-2048 Key Pair" -ForegroundColor Yellow
Write-Host "--------------------------------------------" -ForegroundColor Gray
& (Join-Path $scriptDir "LicenseManager-CLI.ps1") -Action GenerateKeys

# Wait for user
Write-Host "`nPress any key to continue to Step 2..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Step 2: Create Sample Licenses
Write-Host "`n`nStep 2: Creating Sample Licenses" -ForegroundColor Yellow
Write-Host "--------------------------------------------" -ForegroundColor Gray

Write-Host "`nCreating License 1 - Standard License..." -ForegroundColor Green
& (Join-Path $scriptDir "LicenseManager-CLI.ps1") -Action CreateLicense `
    -LicenseNo "DEMO-STD-001" `
    -AppCode "BC-EXT-001" `
    -CustomerName "Contoso Corporation" `
    -CustomerNo "CUST-001" `
    -ValidFrom "2025-01-01" `
    -ValidTo "2025-12-31" `
    -MaxUsers 25 `
    -Features "SALES,PURCHASE,INVENTORY"

Write-Host "`nCreating License 2 - Premium License..." -ForegroundColor Green
& (Join-Path $scriptDir "LicenseManager-CLI.ps1") -Action CreateLicense `
    -LicenseNo "DEMO-PRE-001" `
    -AppCode "BC-EXT-001" `
    -CustomerName "Fabrikam Industries" `
    -CustomerNo "CUST-002" `
    -ValidFrom "2025-01-01" `
    -ValidTo "2026-12-31" `
    -MaxUsers -1 `
    -Features "SALES,PURCHASE,INVENTORY,WAREHOUSE,ANALYTICS,REPORTING,API"

Write-Host "`nCreating License 3 - Trial License..." -ForegroundColor Green
& (Join-Path $scriptDir "LicenseManager-CLI.ps1") -Action CreateLicense `
    -LicenseNo "DEMO-TRL-001" `
    -AppCode "BC-EXT-002" `
    -CustomerName "Adventure Works" `
    -CustomerNo "CUST-003" `
    -ValidFrom "2025-01-01" `
    -ValidTo "2025-02-01" `
    -MaxUsers 5 `
    -Features "SALES,PURCHASE,INVENTORY"

# Wait for user
Write-Host "`nPress any key to continue to Step 3..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Step 3: Sign Licenses
Write-Host "`n`nStep 3: Signing Licenses with RSA-2048" -ForegroundColor Yellow
Write-Host "--------------------------------------------" -ForegroundColor Gray

Write-Host "`nSigning Standard License..." -ForegroundColor Green
& (Join-Path $scriptDir "LicenseManager-CLI.ps1") -Action SignLicense -LicenseNo "DEMO-STD-001"

Write-Host "`nSigning Premium License..." -ForegroundColor Green
& (Join-Path $scriptDir "LicenseManager-CLI.ps1") -Action SignLicense -LicenseNo "DEMO-PRE-001"

Write-Host "`nSigning Trial License..." -ForegroundColor Green
& (Join-Path $scriptDir "LicenseManager-CLI.ps1") -Action SignLicense -LicenseNo "DEMO-TRL-001"

# Wait for user
Write-Host "`nPress any key to continue to Step 4..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Step 4: Verify Licenses
Write-Host "`n`nStep 4: Verifying License Signatures" -ForegroundColor Yellow
Write-Host "--------------------------------------------" -ForegroundColor Gray

Write-Host "`nVerifying Standard License..." -ForegroundColor Green
& (Join-Path $scriptDir "LicenseManager-CLI.ps1") -Action VerifyLicense -LicenseNo "DEMO-STD-001"

Write-Host "`nVerifying Premium License..." -ForegroundColor Green
& (Join-Path $scriptDir "LicenseManager-CLI.ps1") -Action VerifyLicense -LicenseNo "DEMO-PRE-001"

Write-Host "`nVerifying Trial License..." -ForegroundColor Green
& (Join-Path $scriptDir "LicenseManager-CLI.ps1") -Action VerifyLicense -LicenseNo "DEMO-TRL-001"

# Summary
Write-Host "`n`n==========================================" -ForegroundColor Cyan
Write-Host "  Demonstration Complete!" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

Write-Host "`nGenerated Files:" -ForegroundColor Yellow
Write-Host "  Keys:" -ForegroundColor White
Write-Host "    - Private key stored securely (never share)" -ForegroundColor White
Write-Host "    - Public key for distribution" -ForegroundColor White
Write-Host "`n  Licenses:" -ForegroundColor White
Write-Host "    - $scriptDir\Licenses\DEMO-STD-001.txt" -ForegroundColor White
Write-Host "    - $scriptDir\Licenses\DEMO-STD-001.signed.txt" -ForegroundColor White
Write-Host "    - $scriptDir\Licenses\DEMO-PRE-001.txt" -ForegroundColor White
Write-Host "    - $scriptDir\Licenses\DEMO-PRE-001.signed.txt" -ForegroundColor White
Write-Host "    - $scriptDir\Licenses\DEMO-TRL-001.txt" -ForegroundColor White
Write-Host "    - $scriptDir\Licenses\DEMO-TRL-001.signed.txt" -ForegroundColor White

Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "  1. Import licenses into Business Central" -ForegroundColor White
Write-Host "  2. Configure application registry" -ForegroundColor White
Write-Host "  3. Test license validation in BC" -ForegroundColor White
Write-Host "  4. Distribute public key for verification" -ForegroundColor White

Write-Host "`nFor more information, see README.md" -ForegroundColor Cyan
Write-Host "`n==========================================`n" -ForegroundColor Cyan
