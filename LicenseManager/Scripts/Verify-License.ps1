<#
.SYNOPSIS
    Verify a Business Central license signature.

.DESCRIPTION
    This script verifies the RSA digital signature of a license file to ensure
    authenticity and detect tampering. Uses RSA-2048 public key for verification.

.PARAMETER LicenseData
    The original license data string.

.PARAMETER Signature
    The Base64-encoded signature to verify.

.PARAMETER PublicKeyPath
    Path to the RSA public key XML file.

.EXAMPLE
    .\Verify-License.ps1 -LicenseData "LICENSE|APP001|..." -Signature "ABC123..." -PublicKeyPath ".\Keys\LicenseKey.public.xml"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$LicenseData,
    
    [Parameter(Mandatory=$true)]
    [string]$Signature,
    
    [Parameter(Mandatory=$true)]
    [string]$PublicKeyPath
)

# Import required assemblies
Add-Type -AssemblyName System.Security

try {
    # Verify public key file exists
    if (-not (Test-Path $PublicKeyPath)) {
        throw "Public key file not found: $PublicKeyPath"
    }
    
    Write-Host "Loading public key..." -ForegroundColor Cyan
    $publicKeyXml = Get-Content -Path $PublicKeyPath -Raw
    
    # Create RSA provider and import public key
    $rsa = [System.Security.Cryptography.RSACryptoServiceProvider]::new()
    $rsa.FromXmlString($publicKeyXml)
    
    Write-Host "Verifying license signature..." -ForegroundColor Cyan
    
    # Convert license data to bytes
    $dataBytes = [System.Text.Encoding]::UTF8.GetBytes($LicenseData)
    
    # Create SHA-256 hash
    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    $hashBytes = $sha256.ComputeHash($dataBytes)
    
    # Convert signature from Base64
    $signatureBytes = [Convert]::FromBase64String($Signature)
    
    # Verify the signature
    $isValid = $rsa.VerifyHash($hashBytes, [System.Security.Cryptography.CryptoConfig]::MapNameToOID("SHA256"), $signatureBytes)
    
    if ($isValid) {
        Write-Host "`nVerification Result: VALID" -ForegroundColor Green
        Write-Host "  The license signature is authentic" -ForegroundColor White
        Write-Host "  No tampering detected" -ForegroundColor White
    } else {
        Write-Host "`nVerification Result: INVALID" -ForegroundColor Red
        Write-Host "  The license signature is NOT authentic" -ForegroundColor White
        Write-Host "  License may have been tampered with" -ForegroundColor White
    }
    
    Write-Host "`nVerification Details:" -ForegroundColor Yellow
    Write-Host "  Algorithm: RSA-2048-SHA256" -ForegroundColor White
    Write-Host "  Data Hash: $([Convert]::ToBase64String($hashBytes))" -ForegroundColor White
    
    $rsa.Dispose()
    $sha256.Dispose()
    
    # Return verification result
    return $isValid
    
} catch {
    Write-Host "Error verifying license: $_" -ForegroundColor Red
    exit 1
}
