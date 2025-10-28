<#
.SYNOPSIS
    Generate RSA-2048 key pair for license signing.

.DESCRIPTION
    This script generates a public/private RSA-2048 key pair for signing
    and verifying Business Central licenses. The keys are stored in XML format.

.PARAMETER KeyPath
    The directory path where the keys will be saved. Default is ./Keys

.PARAMETER KeyName
    The base name for the key files. Default is "LicenseKey"

.EXAMPLE
    .\Generate-RSAKeys.ps1
    Generates keys in ./Keys directory with default names

.EXAMPLE
    .\Generate-RSAKeys.ps1 -KeyPath "C:\SecureKeys" -KeyName "MyLicense"
    Generates keys in specified directory with custom name
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$KeyPath = (Join-Path $PSScriptRoot "Keys"),
    
    [Parameter(Mandatory=$false)]
    [string]$KeyName = "LicenseKey"
)

# Import required .NET assemblies
Add-Type -AssemblyName System.Security

# Ensure the key directory exists
if (-not (Test-Path $KeyPath)) {
    New-Item -ItemType Directory -Path $KeyPath -Force | Out-Null
    Write-Host "Created directory: $KeyPath" -ForegroundColor Green
}

try {
    Write-Host "Generating RSA-2048 key pair..." -ForegroundColor Cyan
    
    # Create RSA provider with 2048-bit key size
    $rsa = [System.Security.Cryptography.RSACryptoServiceProvider]::new(2048)
    
    # Export private key (includes both public and private parameters)
    $privateKeyXml = $rsa.ToXmlString($true)
    $privateKeyPath = Join-Path $KeyPath "$KeyName.private.xml"
    $privateKeyXml | Out-File -FilePath $privateKeyPath -Encoding UTF8
    Write-Host "Private key saved successfully (location not displayed for security)" -ForegroundColor Green
    
    # Export public key (includes only public parameters)
    $publicKeyXml = $rsa.ToXmlString($false)
    $publicKeyPath = Join-Path $KeyPath "$KeyName.public.xml"
    $publicKeyXml | Out-File -FilePath $publicKeyPath -Encoding UTF8
    Write-Host "Public key saved to: $publicKeyPath" -ForegroundColor Green
    
    # Display key information
    Write-Host "`nKey Information:" -ForegroundColor Yellow
    Write-Host "  Key Size: 2048 bits" -ForegroundColor White
    Write-Host "  Key Directory: $KeyPath" -ForegroundColor White
    Write-Host "  Private Key: Protected (not displayed for security)" -ForegroundColor White
    Write-Host "  Public Key: $KeyName.public.xml" -ForegroundColor White
    
    Write-Host "`nSecurity Notice:" -ForegroundColor Red
    Write-Host "  - Keep the private key secure and confidential" -ForegroundColor White
    Write-Host "  - The public key can be distributed freely" -ForegroundColor White
    Write-Host "  - Never commit the private key to source control" -ForegroundColor White
    
    # Create .gitignore to protect private keys
    $gitignorePath = Join-Path $KeyPath ".gitignore"
    "*.private.xml`n*.private.*`nprivate/" | Out-File -FilePath $gitignorePath -Encoding UTF8
    Write-Host "`nCreated .gitignore to protect private keys" -ForegroundColor Green
    
    $rsa.Dispose()
    
    Write-Host "`nKey pair generation completed successfully!" -ForegroundColor Green
    
} catch {
    Write-Host "Error generating key pair: $_" -ForegroundColor Red
    exit 1
}
