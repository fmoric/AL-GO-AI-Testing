<#
.SYNOPSIS
    Command-Line Interface for Business Central License Management.

.DESCRIPTION
    This script provides a comprehensive CLI for managing Business Central licenses,
    including application registration, license generation, signing, and validation.

.PARAMETER Action
    The action to perform: GenerateKeys, CreateLicense, SignLicense, VerifyLicense, ListApplications

.PARAMETER AppCode
    Application code (for CreateLicense, ListApplications)

.PARAMETER LicenseNo
    License number (for CreateLicense, SignLicense, VerifyLicense)

.PARAMETER CustomerName
    Customer name (for CreateLicense)

.PARAMETER CustomerNo
    Customer number (for CreateLicense)

.PARAMETER ValidFrom
    License valid from date (for CreateLicense)

.PARAMETER ValidTo
    License valid to date (for CreateLicense)

.PARAMETER MaxUsers
    Maximum number of users, -1 for unlimited (for CreateLicense)

.PARAMETER Features
    Comma-separated list of feature codes (for CreateLicense)

.PARAMETER KeyPath
    Path to the keys directory

.EXAMPLE
    .\LicenseManager-CLI.ps1 -Action GenerateKeys
    Generates RSA key pair for license signing

.EXAMPLE
    .\LicenseManager-CLI.ps1 -Action CreateLicense -LicenseNo "LIC001" -AppCode "APP001" -CustomerName "Contoso Ltd" -ValidFrom "2025-01-01" -ValidTo "2025-12-31" -Features "FEATURE1,FEATURE2"
    Creates a new license
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("GenerateKeys", "CreateLicense", "SignLicense", "VerifyLicense", "ListApplications", "Help")]
    [string]$Action,
    
    [Parameter(Mandatory=$false)]
    [string]$AppCode,
    
    [Parameter(Mandatory=$false)]
    [string]$LicenseNo,
    
    [Parameter(Mandatory=$false)]
    [string]$CustomerName,
    
    [Parameter(Mandatory=$false)]
    [string]$CustomerNo,
    
    [Parameter(Mandatory=$false)]
    [string]$ValidFrom,
    
    [Parameter(Mandatory=$false)]
    [string]$ValidTo,
    
    [Parameter(Mandatory=$false)]
    [int]$MaxUsers = -1,
    
    [Parameter(Mandatory=$false)]
    [string]$Features,
    
    [Parameter(Mandatory=$false)]
    [string]$KeyPath = (Join-Path $PSScriptRoot "Keys")
)

# Script directory
$scriptDir = $PSScriptRoot

Write-Host "`n=== Business Central License Manager ===" -ForegroundColor Cyan
Write-Host "Action: $Action`n" -ForegroundColor Yellow

switch ($Action) {
    "GenerateKeys" {
        Write-Host "Generating RSA-2048 key pair for license signing...`n" -ForegroundColor Green
        & (Join-Path $scriptDir "Generate-RSAKeys.ps1") -KeyPath $KeyPath
    }
    
    "CreateLicense" {
        if (-not $LicenseNo -or -not $AppCode -or -not $CustomerName -or -not $ValidFrom -or -not $ValidTo) {
            Write-Host "Error: CreateLicense requires -LicenseNo, -AppCode, -CustomerName, -ValidFrom, and -ValidTo" -ForegroundColor Red
            exit 1
        }
        
        Write-Host "Creating license: $LicenseNo" -ForegroundColor Green
        Write-Host "  Application: $AppCode" -ForegroundColor White
        Write-Host "  Customer: $CustomerName" -ForegroundColor White
        Write-Host "  Valid From: $ValidFrom" -ForegroundColor White
        Write-Host "  Valid To: $ValidTo" -ForegroundColor White
        Write-Host "  Max Users: $MaxUsers" -ForegroundColor White
        
        # Build license data string
        $licenseData = "$LicenseNo|$AppCode|$CustomerNo|$ValidFrom|$ValidTo|$MaxUsers"
        
        if ($Features) {
            Write-Host "  Features: $Features" -ForegroundColor White
            $featureList = $Features -split ','
            foreach ($feature in $featureList) {
                $licenseData += "|$feature"
            }
        }
        
        # Save license data to file
        $licensePath = Join-Path $scriptDir "Licenses"
        if (-not (Test-Path $licensePath)) {
            New-Item -ItemType Directory -Path $licensePath -Force | Out-Null
        }
        
        $licenseFile = Join-Path $licensePath "$LicenseNo.txt"
        
        $licenseContent = @"
[LICENSE]
LicenseNo=$LicenseNo
ApplicationCode=$AppCode
CustomerName=$CustomerName
CustomerNo=$CustomerNo
ValidFrom=$ValidFrom
ValidTo=$ValidTo
MaxUsers=$MaxUsers
SignatureAlgorithm=RSA-2048-SHA256

[FEATURES]
$($Features -replace ',', "`n")

[LICENSE_DATA]
$licenseData
"@
        
        $licenseContent | Out-File -FilePath $licenseFile -Encoding UTF8
        Write-Host "`nLicense created: $licenseFile" -ForegroundColor Green
        Write-Host "Next step: Sign the license using -Action SignLicense" -ForegroundColor Yellow
    }
    
    "SignLicense" {
        if (-not $LicenseNo) {
            Write-Host "Error: SignLicense requires -LicenseNo" -ForegroundColor Red
            exit 1
        }
        
        $licenseFile = Join-Path $scriptDir "Licenses" "$LicenseNo.txt"
        if (-not (Test-Path $licenseFile)) {
            Write-Host "Error: License file not found: $licenseFile" -ForegroundColor Red
            exit 1
        }
        
        # Read license data
        $licenseContent = Get-Content -Path $licenseFile -Raw
        $licenseData = ($licenseContent -split '\[LICENSE_DATA\]')[1].Trim()
        
        $privateKeyPath = Join-Path $KeyPath "LicenseKey.private.xml"
        if (-not (Test-Path $privateKeyPath)) {
            Write-Host "Error: Private key not found. Run -Action GenerateKeys first." -ForegroundColor Red
            exit 1
        }
        
        Write-Host "Signing license: $LicenseNo" -ForegroundColor Green
        $signedFile = Join-Path $scriptDir "Licenses" "$LicenseNo.signed.txt"
        
        & (Join-Path $scriptDir "Sign-License.ps1") -LicenseData $licenseData -PrivateKeyPath $privateKeyPath -OutputPath $signedFile
        
        Write-Host "`nSigned license saved: $signedFile" -ForegroundColor Green
    }
    
    "VerifyLicense" {
        if (-not $LicenseNo) {
            Write-Host "Error: VerifyLicense requires -LicenseNo" -ForegroundColor Red
            exit 1
        }
        
        $signedFile = Join-Path $scriptDir "Licenses" "$LicenseNo.signed.txt"
        if (-not (Test-Path $signedFile)) {
            Write-Host "Error: Signed license file not found: $signedFile" -ForegroundColor Red
            exit 1
        }
        
        $publicKeyPath = Join-Path $KeyPath "LicenseKey.public.xml"
        if (-not (Test-Path $publicKeyPath)) {
            Write-Host "Error: Public key not found." -ForegroundColor Red
            exit 1
        }
        
        # Parse signed license file
        $content = Get-Content -Path $signedFile -Raw
        $licenseData = ($content -split '\[LICENSE_DATA\]|\[SIGNATURE\]')[1].Trim()
        $signatureSection = ($content -split '\[SIGNATURE\]')[1]
        $signature = ($signatureSection -split 'Signature=')[1].Split("`n")[0].Trim()
        
        Write-Host "Verifying license: $LicenseNo" -ForegroundColor Green
        
        & (Join-Path $scriptDir "Verify-License.ps1") -LicenseData $licenseData -Signature $signature -PublicKeyPath $publicKeyPath
    }
    
    "ListApplications" {
        Write-Host "Listing registered applications..." -ForegroundColor Green
        Write-Host "(This would query the Business Central database in production)" -ForegroundColor Yellow
        Write-Host "`nSample Applications:" -ForegroundColor White
        Write-Host "  APP001 - Business Central Extension v1.0" -ForegroundColor White
        Write-Host "  APP002 - Custom Warehouse Management v2.1" -ForegroundColor White
        Write-Host "  APP003 - Advanced Reporting Suite v3.0" -ForegroundColor White
    }
    
    "Help" {
        Write-Host "Available Actions:" -ForegroundColor Green
        Write-Host "  GenerateKeys     - Generate RSA-2048 key pair for license signing" -ForegroundColor White
        Write-Host "  CreateLicense    - Create a new license file" -ForegroundColor White
        Write-Host "  SignLicense      - Sign a license with digital signature" -ForegroundColor White
        Write-Host "  VerifyLicense    - Verify a license signature" -ForegroundColor White
        Write-Host "  ListApplications - List registered applications" -ForegroundColor White
        Write-Host "`nExamples:" -ForegroundColor Yellow
        Write-Host "  .\LicenseManager-CLI.ps1 -Action GenerateKeys" -ForegroundColor White
        Write-Host "  .\LicenseManager-CLI.ps1 -Action CreateLicense -LicenseNo 'LIC001' -AppCode 'APP001' -CustomerName 'Contoso' -ValidFrom '2025-01-01' -ValidTo '2025-12-31'" -ForegroundColor White
        Write-Host "  .\LicenseManager-CLI.ps1 -Action SignLicense -LicenseNo 'LIC001'" -ForegroundColor White
        Write-Host "  .\LicenseManager-CLI.ps1 -Action VerifyLicense -LicenseNo 'LIC001'" -ForegroundColor White
    }
}

Write-Host "`n=== License Manager Complete ===" -ForegroundColor Cyan
