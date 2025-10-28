<#
.SYNOPSIS
    Sign a Business Central license file with RSA digital signature.

.DESCRIPTION
    This script generates a cryptographic signature for a license using RSA-2048
    private key and SHA-256 hashing algorithm. The signature ensures license
    authenticity and prevents tampering.

.PARAMETER LicenseData
    The license data string to be signed.

.PARAMETER PrivateKeyPath
    Path to the RSA private key XML file.

.PARAMETER OutputPath
    Optional path for the signed license file. If not specified, outputs to console.

.EXAMPLE
    .\Sign-License.ps1 -LicenseData "LICENSE|APP001|..." -PrivateKeyPath ".\Keys\LicenseKey.private.xml"

.EXAMPLE
    .\Sign-License.ps1 -LicenseData "LICENSE|APP001|..." -PrivateKeyPath ".\Keys\LicenseKey.private.xml" -OutputPath ".\license.signed"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$LicenseData,
    
    [Parameter(Mandatory=$true)]
    [string]$PrivateKeyPath,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath
)

# Import required assemblies
Add-Type -AssemblyName System.Security

try {
    # Verify private key file exists
    if (-not (Test-Path $PrivateKeyPath)) {
        throw "Private key file not found: $PrivateKeyPath"
    }
    
    Write-Host "Loading private key..." -ForegroundColor Cyan
    $privateKeyXml = Get-Content -Path $PrivateKeyPath -Raw
    
    # Create RSA provider and import private key
    $rsa = [System.Security.Cryptography.RSACryptoServiceProvider]::new()
    $rsa.FromXmlString($privateKeyXml)
    
    Write-Host "Signing license data..." -ForegroundColor Cyan
    
    # Convert license data to bytes
    $dataBytes = [System.Text.Encoding]::UTF8.GetBytes($LicenseData)
    
    # Create SHA-256 hash
    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    $hashBytes = $sha256.ComputeHash($dataBytes)
    
    # Sign the hash with RSA
    $signature = $rsa.SignHash($hashBytes, [System.Security.Cryptography.CryptoConfig]::MapNameToOID("SHA256"))
    
    # Convert signature to Base64 for storage
    $signatureBase64 = [Convert]::ToBase64String($signature)
    
    if ($OutputPath) {
        # Create signed license file
        $signedLicense = @"
[LICENSE_DATA]
$LicenseData

[SIGNATURE]
Algorithm=RSA-2048-SHA256
Signature=$signatureBase64
SignedDate=$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

[HASH]
$([Convert]::ToBase64String($hashBytes))
"@
        
        $signedLicense | Out-File -FilePath $OutputPath -Encoding UTF8
        Write-Host "Signed license saved to: $OutputPath" -ForegroundColor Green
    } else {
        Write-Host "`nSignature (Base64):" -ForegroundColor Yellow
        Write-Host $signatureBase64 -ForegroundColor White
    }
    
    Write-Host "`nLicense signed successfully!" -ForegroundColor Green
    Write-Host "  Algorithm: RSA-2048-SHA256" -ForegroundColor White
    Write-Host "  Signature Length: $($signature.Length) bytes" -ForegroundColor White
    
    $rsa.Dispose()
    $sha256.Dispose()
    
    # Return signature for programmatic use
    return $signatureBase64
    
} catch {
    Write-Host "Error signing license: $_" -ForegroundColor Red
    exit 1
}
